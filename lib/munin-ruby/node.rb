require 'digest/md5'

module Munin
  class Node
    include Munin::Parser
    include Munin::Cache
    
    attr_reader :connection
    
    # Initialize a new Node instance
    #
    # host      - Server host
    # port      - Server port
    # reconnect - Reconnect if connection was closed (default: true)
    #
    
    def initialize(host='127.0.0.1', port=4949, reconnect=true)
      @connection = Munin::Connection.new(host, port, reconnect)
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
      cache 'nodes' do 
        connection.send_data("nodes")
        connection.read_line.split
      end
    end
    
    # Get a list of all available metrics
    #
    def list(node = nil)
      cache "list_#{node || 'default'}" do
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
