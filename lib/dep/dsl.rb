class Dep
  class Dsl < Hash

    def call(&block)
      instance_eval(&block) if block_given?
      self
    end
    
    def get(key, index=nil)
      if index
        self[key][index] rescue nil
      else
        self[key] || [ nil, {}, {} ]
      end
    end

    def method_missing(method, *args, &block)
      value = args.detect { |a| a.class != Hash }
      options = args.detect { |a| a.class == Hash }
      if self[method] && value.nil? && options.nil?
        self.get(method, 0)
      else
        self[method] = [
          value,
          options || {},
          block_given? ? Dsl.new.call(&block) : {}
        ]
      end
    end
  end
end