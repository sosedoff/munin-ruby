module Munin
  class Stat
    attr_reader :name, :params
    
    def initialize(name, rows=[])
      @name = name
      @params = {}
      unless rows.empty?
        rows.each do |r|
          name = r.first.scan(/^([a-z\d\_\-]{1,}).value/i).to_s
          @params[name] = r.last
        end
      end
    end
    
    def to_s
      "Munin::Stat<#{@name}>"
    end
  end
end
