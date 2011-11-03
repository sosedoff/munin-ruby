require 'socket'

module Munin
  class Connection
    include Munin::Parser
    
    attr_reader :host, :port
    
    # Initialize a new connection to munin-node server
    #
    # host - Server host (default: 127.0.0.1)
    # port - Server port (default: 4949)
    #
    def initialize(host='127.0.0.1', port=4949)
      @host      = host
      @port      = port
      @socket    = nil
      @connected = false
    end
    
    # Returns true if socket is connected
    #
    def connected?
      @connected == true
    end
    
    # Establish connection to the server
    #
    def connect
      begin
        @socket = TCPSocket.new(@host, @port)
        @socket.sync = true
        welcome = @socket.gets
      rescue Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::ECONNRESET => ex
        raise Munin::ConnectionError, ex.message
      rescue EOFError
        raise Munin::AccessDenied
      end
    end
    
    # Close connection
    #
    def close
      @socket.close unless @socket.nil?
    end
    
    # Send a string of data followed by a newline symbol
    #
    def send_data(str)
      connect unless connected?
      @socket.puts("#{str.strip}\n")
    end
    
    # Reads a single line from socket
    #
    def read_line
      @socket.gets.strip
    end
    
    # Reads a packet of data until '.' reached
    #
    def read_packet
      lines = []
      while(str = @socket.readline) do
        break if str.strip == '.'
        lines << str.strip
      end
      parse_error(lines)
      lines
    end
  end
end