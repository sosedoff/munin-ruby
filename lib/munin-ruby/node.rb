module Munin
  class Node
    attr_reader :host, :port
    attr_reader :version, :services
    attr_reader :timestamp
    
    # Setup a new node
    # host - Server hostname or IP address
    # opts - Options
    #   :port => Node server port (default to 4949)
    #   :fetch => String or Array of service names ONLY to fetch
    def initialize(host, opts={})
      @host          = host
      @port          = opts[:port] || 4949
      @stats         = {}
      @services      = []
      @version       = ''
      @only_services = opts[:fetch] || []

      if @only_services.kind_of?(Array)
        @only_services.uniq!
      elsif @only_services.kind_of?(String)
        @only_services = @only_services.scan(/[a-z\d\-\_]{1,}/i).uniq
      else
        @only_services = []
      end

      run
    end
    
    # Get service stats
    def service(name)
      if @stats.key?(name)
        @stats[name]
      else
        raise Munin::NoSuchService, "Service with name #{name} does not exist."
      end
    end
    
    private
    
    # Fetch node information and stats
    def run
      begin
        @timestamp = Time.now
        @socket = TCPSocket.new(@host, @port)
        @socket.sync = true ; @socket.gets
        fetch_version
        fetch_services
        @socket.close
      rescue Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::ECONNRESET => ex
        raise Munin::SessionError, ex.message
      rescue EOFError
        raise Munin::AccessDenied
      end
    end
    
    # Fetch node server version
    def fetch_version
      @socket.puts("version")
      @version = @socket.readline.strip.split(' ').last
    end
    
    # Fetch list of services and its stats
    def fetch_services
      @socket.puts("list")
      services = @socket.readline.split(' ').map { |s| s.strip }.sort
      services = services.select { |s| @only_services.include?(s) } unless @only_services.empty?
      services.each { |s| @services << s ; @stats[s] = fetch(s) }
    end
    
    # Fetch service information
    def fetch(service)
      @socket.puts("fetch #{service}")
      content = []
      while(str = @socket.readline) do
        break if str.strip == '.'
        content << str.strip.split(' ')
      end
      Stat.new(service, content)
    end
  end
end
