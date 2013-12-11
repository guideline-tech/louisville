module Louisville
  class Config

    DEFAULTS = {
      :column => :slug,
      :finder => true,
      :collision => :none,
      :setter => false,
      :history => false
    }.freeze

    def initialize(field, options = {})
      @options  = DEFAULTS.merge(options).merge(:field => field)

      # if false is provided we still need to use the none case
      @options[:collision] ||= :none
    end

    def hook!(klass)
      modules.each do |modul|
        modul.configure_default_options(@options) if modul.respond_to?(:configure_default_options)
        klass.send(:include, modul)
      end
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
