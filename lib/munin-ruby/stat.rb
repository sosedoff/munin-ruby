module Munin
  class Stat
    attr_reader :name, :params
    
    # Initialize a new Munin::Stat object
    #
    # name - Attribute name
    # rows - Array of parameters
    #
    def initialize(name, rows=[])    
      @name = name
      @params = {}
      unless rows.empty?
        rows.each do |r|
          key = r.first.split('.value').first
          @params[key] = r.last
        end
      end
    end
  end
end
