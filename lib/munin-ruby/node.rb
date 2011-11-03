module Munin
  class Node
    include Munin::Parser
    
    attr_reader :connection
    
    # Initialize a new Node instance
    #
    # host - Server host
    # port - Server port
    #
    def initialize(host='127.0.0.1', port=4949)
      @connection = Munin::Connection.new(host, port)
    end
    
    # Get a node version
    #
    def version
      connection.send_data("version")
      str = connection.read_line
      if str =~  /^munins node on/
        str.split.last
      else
        raise InvalidResponse
      end
    end
    
    # Get a list of all available metrics
    #
    def list
      connection.send_data("list")
      connection.read_line.split
    end
    
    # Get a configuration information for service
    #
    # services - Name of the service, or list of service names
    #
    def config(services)
      return_single = services.kind_of?(String)
      results = []
      names = [services].flatten
      names.each do |service|
        begin
          connection.send_data("config #{service}")
          lines = connection.read_packet
          results << parse_config(lines)
        rescue UnknownService, BadExit
          # TODO
        end
      end
      return_single && results.size == 1 ? results.first : results
    end
    
    # Get all service metrics values
    #
    # services - Name of the service, or list of service names
    #
    def fetch(services)
      return_single = services.kind_of?(String)
      results = []
      names = [services].flatten
      names.each do |service|
        begin
          connection.send_data("fetch #{service}")
          lines = connection.read_packet
          results << parse_fetch(lines)
        rescue UnknownService, BadExit
          # TODO
        end
      end
      return_single && results.size == 1 ? results.first : results
    end
  end
end