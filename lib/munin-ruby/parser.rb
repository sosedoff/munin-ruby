module Munin
  module Parser  
    # Parse a version request
    #
    def parse_version(line)
      if line =~  /^munins node on/
        line.split.last
      else
        raise Munin::InvalidResponse, "Invalid version response"
      end
    end

    # Process response
    #
    def process_data(lines)  
      data = {}
      lines.each do |line|
        line = line.split
        key = line.first.split('.value').first
        data[key] = line.last
      end
      data
    end

    # Parse 'config' request
    #
    def parse_config(data)
      config = {'graph' => {}, 'metrics' => {}}
      data.each do |l|
        if l =~ /^graph_/
          key_name, value = l.scan(/^graph_([\w]+)\s(.*)/).flatten
          config['graph'][key_name] = value
        # according to http://munin-monitoring.org/wiki/notes_on_datasource_names
        elsif l =~ /^[a-zA-Z_][a-zA-Z\d_]*\./
          # according to http://munin-monitoring.org/wiki/fieldnames the second one
          # can only be [a-z]
          matches = l.scan(/^([a-zA-Z_][a-zA-Z\d_]*)\.([a-z]+)\s(.*)/).flatten
          config['metrics'][matches[0]] ||= {}
          config['metrics'][matches[0]][matches[1]] = matches[2]
        end
      end

      # Now, lets process the args hash
      if config['graph'].key?('args')
        config['graph']['args'] = parse_config_args(config['graph']['args'])
      end

      config
    end

    # Parse 'fetch' request
    #
    def parse_fetch(data)
      process_data(data)
    end

    # Detect error from output
    #
    def parse_error(lines)
      if lines.size == 1
        case lines.first
          when '# Unknown service' then raise UnknownService
          when '# Bad exit'        then raise BadExit
        end
      end
    end

    # Parse configuration arguments
    #
    def parse_config_args(args)
      result = {}
      args.scan(/--?([a-z\-\_]+)\s([\d]+)\s?/).each do |arg|
        result[arg.first] = arg.last
      end
      {'raw' => args, 'parsed' => result}
    end
  end
end
