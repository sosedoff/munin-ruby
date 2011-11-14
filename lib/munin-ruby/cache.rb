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
    
    protected
    
    def cache_key(key)
      "@cache_#{key}".to_sym
    end
      
    def cache_get(key)
      instance_variable_get(cache_key(key))
    end
    
    def cache_set(key, value)
      instance_variable_set(cache_key(key), value)
    end
  end
end
