module Louisville
  class Config

    DEFAULTS = {
      :column => :slug,
      :finder => true,
      :collision => :none,
      :setter => false,
      :history => false
    }

    def initialize(field, options = {})
      @options  = DEFAULTS.merge(options).merge(:field => field)

      # if false is provided we still need to use the none case
      @options[:collision] ||= :none
      @options[:setter]      = "desired_#{@options[:column]}" if @options[:setter] == true
    end

    def hook!(klass)
      modules.each do |modul|
        klass.send(:include, modul)
      end
    end

    def numeric?(id)
      Integer === id || !!(id.to_s =~ /^[\d]+$/)
    end

    def option?(key)
      !!option(key)
    end

    def option(key)
      @options[key]
    end
    alias_method :[], :option

    def options_for(key)
      return self[key] if self[key] === Hash
      {}
    end

    def collision_resolver_class
      class_name = options_for(:collision)[:resolver] || option(:collision)
      Louisville::CollisionResolvers.const_get(:"#{class_name.to_s.classify}")
    end

    def extension_keys
      (@options.keys - [:column, :field])
    end

    protected

    def modules
      extension_keys.map do |option|
        ::Louisville::Extensions.const_get(option.to_s.classify) if self.option?(option)
      end.compact
    end

  end
end
