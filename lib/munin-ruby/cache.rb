module Munin
  module Cache
    def cache(key)
      raise RuntimeError, "Block required." unless block_given?
      data = cache_get(key)
      if data.nil?
        data = yield
        cache_set(key, data)
      end
      data
    end
    
    def flush_cache
      instance_variables.select { |l| l =~ /^@cache_/ }.each do |var|
        remove_instance_variable(var)
      end
      true
    end
    
    protected
    
    def cache_key(key)
      "@cache_#{key.gsub(/[\.-]/,'__')}".to_sym
    end
      
    def cache_get(key)
      instance_variable_get(cache_key(key))
    end
    
    def cache_set(key, value)
      instance_variable_set(cache_key(key), value)
    end
  end
end
