module Louisville
  class Config

    DEFAULTS = {
      :column => :slug,
      :finder => true,
      :collision => false,
      :setter => false
    }

    def initialize(field, options = {})
      @options  = DEFAULTS.merge(options).merge(:field => @field)
    end

    def hook!(klass)
      modules.each do |modul|
        klass.include modul
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
      class_name.to_s.classify.contantize
    end

    def extension_keys
      (@options.keys - [:column, :field])
    end

    protected

    def modules
      extension_keys.map do |option|
        ::Louisville::Extensions.const_get(option.to_s.classify)
      end
    end

  end 