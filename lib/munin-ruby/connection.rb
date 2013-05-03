module Munin
  class Connection
    include Munin::Parser

    DEFAULT_OPTIONS = {:timeout => Munin::TIMEOUT_TIME}

    attr_reader :host, :port
    
    # Initialize a new connection to munin-node server
    #
    # host    - Server host (default: 127.0.0.1)
    # port    - Server port (default: 4949)
    # options - A hash containing different options
    #    :timeout => A timeout in seconds to be used in the connection

    def initialize(host='127.0.0.1', port=4949, reconnect=true, options = {})
      @host      = host
      @port      = port
      @socket    = nil
      @connected = false
      @reconnect = reconnect
      @options    = DEFAULT_OPTIONS.merge(options)
    end
    
    # Returns true if socket is connected
    #
    def connected?
      @connected == true
    end
    
    # Establish connection to the server
    #
    def open
      begin
        begin
          with_timeout do
            @socket = TCPSocket.new(@host, @port)
            @socket.sync = true
            welcome = @socket.gets
            unless welcome =~ /^# munin node at/
              raise Munin::AccessDenied
            end
            @connected = true
          end
        rescue Timeout::Error
          raise Munin::ConnectionError, "Timed out talking to #{@host}"
        end
      rescue Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::ECONNRESET => ex
        raise Munin::ConnectionError, ex.message
      rescue EOFError
        raise Munin::AccessDenied
      rescue Exception => ex
        raise Munin::ConnectionError, ex.message
      end
    end
    
    # Close connection
    #
    def close(reconnect=true)
      if connected?
        @socket.flush
        @socket.shutdown
        @connected = false
        @reconnect = reconnect
      end
    end
    
    # Send a string of data followed by a newline symbol
    #
    def send_data(str)
      if !connected?
        if !@socket.nil? && @reconnect == false
          raise Munin::ConnectionError, "Not connected."
        else
          open
        end
      end

      begin
        with_timeout { @socket.puts("#{str.strip}\n") }
      rescue Timeout::Error
        raise Munin::ConnectionError, "Timed out on #{@host} trying to send."
      end
    end
    
    # Reads a single line from socket
    #
    def read_line
      begin
        with_timeout { @socket.gets.to_s.strip }
      rescue Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError => ex
        raise Munin::ConnectionError, ex.message
      rescue Timeout::Error
        raise Munin::ConnectionError, "Timed out reading from #{@host}."
      end
    end
    
    # Reads a packet of data until '.' reached
    #
    def read_packet
      begin
        with_timeout do
          lines = []
          while(str = @socket.readline.to_s) do
            break if str.strip == '.'
            lines << str.strip
          end
          parse_error(lines)
          lines
        end
      rescue Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError => ex
        raise Munin::ConnectionError, ex.message
      rescue Timeout::Error
        raise Munin::ConnectionError, "Timed out reading from #{@host}."
      end
    end

    private

    # Execute operation with timeout
    # @param [Block] block Block to execute
    def with_timeout(time=@options[:timeout])
      raise ArgumentError, "Block required" if !block_given?
      if Munin::TIMEOUT_CLASS.respond_to?(:timeout_after)
        Munin::TIMEOUT_CLASS.timeout_after(time) { yield }
      else
        Munin::TIMEOUT_CLASS.timeout(time) { yield }
      end
    end
  end
end
