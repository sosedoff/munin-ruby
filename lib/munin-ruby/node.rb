module Munin
  class Node
    attr_reader :host, :port
    attr_reader :stats, :version, :services
    
    def initialize(host, port=4949)
      @host = host
      @port = port
      @stats = {}
      @services = []
      @version = ''
      run
    end
    
    def service(s)
      @stats[s]
    end
    
    private
    
    def run
      begin
        @socket = TCPSocket.new(@host, @port)
        @socket.sync = true ; @socket.gets
        fetch_version
        fetch_services
        @socket.close
      rescue Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError => ex
        raise Munin::SessionError, ex.message
      end
    end
    
    def fetch_version
      @socket.puts("version")
      @version = @socket.readline.strip.split(' ').last
    end
    
    def fetch_services
      @socket.puts("list")
      services = @socket.readline.split(' ').map { |s| s.strip }
      services.each { |s| @services << s ; @stats[s] = fetch(s) }
    end
    
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