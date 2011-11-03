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
    # service - Name of the service
    #
    def config(service)
      connection.send_data("config #{service}")
      lines = connection.read_packet
      parse_config(lines)
    end
    
    # Get all service metrics values
    #
    # service - Name of the service
    #
    def fetch(service)
      connection.send_data("fetch #{service}")
      lines = connection.read_packet
      parse_fetch(lines)
    end
  end
end