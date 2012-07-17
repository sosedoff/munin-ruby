require 'socket'
require 'rubygems'
begin
  require 'system_timer'
  MyTimer = SystemTimer
rescue LoadError
  require 'timeout'
  MyTimer = Timeout
end


module Munin
  class Connection
    include Munin::Parser
    
    attr_reader :host, :port
    
    # Initialize a new connection to munin-node server
    #
    # host - Server host (default: 127.0.0.1)
    # port - Server port (default: 4949)
    #
    def initialize(host='127.0.0.1', port=4949, reconnect=true)
      @host      = host
      @port      = port
      @socket    = nil
      @connected = false
      @reconnect = reconnect
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
          MyTimer.timeout_after(10) do
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
          begin
            open
          rescue => e
            $stderr.puts "Failed to send data to #{@host} due to #{e}"
            return false
          end
        end
      end

      begin
        MyTimer.timeout_after(10) do
          @socket.puts("#{str.strip}\n")
        end
      rescue Timeout::Error
        raise Munin::ConnectionError, "Timed out on #{@host} trying to send."
      end

    end
    
    # Reads a single line from socket
    #
    def read_line
      begin
        MyTimer.timeout_after(10) do
          @socket.gets.to_s.strip
        end
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
        MyTimer.timeout_after(10) do
          lines = []
          while(str = @socket.readline.to_s) do
            break if str.strip == '.'
            lines << str.strip
          end
        end
        parse_error(lines)
        lines
      rescue Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError => ex
        raise Munin::ConnectionError, ex.message
      rescue Timeout::Error
        raise Munin::ConnectionError, "Timed out reading from #{@host}."
      end
    end
  end
end
