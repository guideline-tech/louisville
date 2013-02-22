module Louisville
  module CollisionResolvers
    class Abstract

      SLUG_MATCHER = /^(.+)--([\d]+)?$/

      def initialize(instance, options = {})
        @instance = instance
        @options  = options
      end

      def unique?
        unique_in_table? && unique_in_history?
      end

      def next_valid_slug
        raise NotImplementedError
      end

      def provides_collision_solution?
        false
      end

      protected

      def unique_in_table?
        raise NotImplementedError
      end

      def using_history?
        config.option?(:history)
      end

      def unique_in_history?
        return true unless using_history?
        
        scope = ::Louisville::Slug.scoped
        scope = scope.where(:sluggable_type => klass.base_class.sti_name)
        scope = scope.where(:slug_base => base_slug)
        scope = scope.where(:slug_sequence => slug_sequence)
        scope = scope.where("#{Louisville::Slug.quoted_table_name}.sluggable_id <> ?", @instance.id) if @instance.persisted?

        scope.exists?
      end

      def unique_in_table?
        scope = klass.scoped
        scope = scope.where("#{klass.quoted_table_name} <> ?", @instance.id) if @instance.persisted?
        scope = scope.where(config[:column] => @instance.louisville_slug)

        scope.exists?
      end


      def config
        @instance.louisville_config
      end

      def klass
        @instance.class
      end

      def slug_base(compare = nil)
        (compare || @instance.louisville_slug.to_s) =~ SLUG_MATCHER
        $1
      end

      def slug_sequence(compare = nil)
        (compare || @instance.louisville_slug.to_s) =~ SLUG_MATCHER
        [$2.to_i, 1].max
      end

      def next_slug(slug)

        base      = slug_base(slug)
        sequence  = slug_sequence(slug)

        "#{base}--#{sequence + 1}"
      end

    end
  end
end