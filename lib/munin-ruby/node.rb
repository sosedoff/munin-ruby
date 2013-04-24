require 'digest/md5'

module Munin
  class Node
    include Munin::Parser
    include Munin::Cache

    attr_reader :connection

    DEFAULT_OPTIONS = {:timeout => Munin::TIMEOUT_TIME}

    # Initialize a new Node instance
    #
    # host      - Server host
    # port      - Server port
    # reconnect - Reconnect if connection was closed (default: true)
    # options   - A hash containing different options
    #    :timeout => A timeout in seconds to be used in the connection
    def initialize(host='127.0.0.1', port=4949, reconnect=true, options = {})
      @options    = DEFAULT_OPTIONS.merge(options)
      @connection = Munin::Connection.new(host, port, reconnect, @options)
    end

    # Open service connection
    #
    def connect
      connection.open
    end
    
    # Close server connection
    #
    def disconnect(reconnect=true)
      connection.close(reconnect)
    end
    
    # Get a node version
    #
    def version
      cache 'version' do
        connection.send_data("version")
        parse_version(connection.read_line)
      end
    end

    # Get a list of all available nodes
    #
    def nodes
      nodes = []
      cache 'nodes' do
        connection.send_data("nodes")
        while ( ( line = connection.read_line ) != "." )
          nodes << line
        end
        nodes
      end
    end
    
    # Get a list of all available metrics
    #
    def list(node = "")
      cache "list_#{node.empty? ? 'default' : node}" do
        connection.send_data("list #{node}")
        if ( line = connection.read_line ) != "."
          line.split
        else
          connection.read_line.split
        end
      end
    end

    # Get a configuration information for service
    #
    # services - Name of the service, or list of service names
    #
    def config(services, raw=false)
      unless [String, Array].include?(services.class)
        raise ArgumentError, "Service(s) argument required"
      end
      
      results       = {}
      names         = [services].flatten.uniq
      
      if names.empty?
        raise ArgumentError, "Service(s) argument required"
      end
      
      key = 'config_' + Digest::MD5.hexdigest(names.to_s) + "_#{raw}"
      
      cache(key) do
        names.each do |service|
          begin
            connection.send_data("config #{service}")
            lines = connection.read_packet 
            results[service] = raw ? lines.join("\n") : parse_config(lines)
          rescue UnknownService, BadExit
            # TODO
          end
        end
        results
      end
    end
    
    # Get all service metrics values
    #
    # services - Name of the service, or list of service names
    #
    def fetch(services)
      unless [String, Array].include?(services.class)
        raise ArgumentError, "Service(s) argument required"
      end
      
      results = {}
      names   = [services].flatten
      
      if names.empty?
        raise ArgumentError, "Service(s) argument required"
      end
      
      names.each do |service|
        begin
          connection.send_data("fetch #{service}")
          lines = connection.read_packet
          results[service] =  parse_fetch(lines)
        rescue UnknownService, BadExit
          # TODO
        end
      end
      results
    end
  end
end
