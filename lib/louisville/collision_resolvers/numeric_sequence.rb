module Louisville
  module CollisionResolvers

    class NumericSequence < Abstract
      

      def provides_collision_solution?
        true
      end

      def next_valid_slug
        [next_valid_slug_from_table, next_valid_slug_from_history].compact.sort.last
      end

      protected

      def next_valid_slug_from_table

        base_field = "#{@instance.louisville_config[:column]}_base"
        sequ_field = "#{@instance.louisville_config[:column]}_sequence"

        scope = klass.scoped
        scope = scope.where(base_field => slug_base)
        scope = scope.where("#{klass.quoted_table_name}.#{klass.primary_key} <> ?", @instance.id) if @instance.persisted?

        "#{slug_base}--#{scope.maximum(sequ_field) + 1}"
      end


      def next_valid_slug_from_history
        scope = ::Louisville::Slug.scoped
        scope = scope.where(:sluggable_type => klass.base_class.sti_name)
        scope = scope.where(:slug_base => slug_base)
        scope = scope.where("#{Louisville::Slug.quoted_table_name}.sluggable_id <> ?", @instance.id) if @instance.persisted?

        "#{slug_base}--#{scope.maximum(:slug_sequence) + 1}"
      end

    end

  end
end