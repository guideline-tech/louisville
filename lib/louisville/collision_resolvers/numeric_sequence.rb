module Louisville
  module CollisionResolvers
    class NumericSequence < Abstract


      def provides_collision_solution?
        true
      end


      def next_valid_slug
        provide_latest_slug(next_valid_slug_from_table, next_valid_slug_from_history)
      end


      def assign_slug(val)
        base, seq = Louisville::Util.slug_parts(val)

        @instance.send("#{config[:column]}=", base)
        @instance.send("#{config[:column]}_sequence=", seq)
      end


      def read_slug
        col = config[:column]
        seq = "#{col}_sequence"

        "#{@instance.send(col)}--#{@instance.send(seq)}"
      end


      def slug_changed?
        @instance.send("#{config[:column]}_changed?") || @instance.send("#{@config[:column]}_sequence_changed?")
      end



      protected



      def unique_in_table?

        base_method     = config[:column]
        sequence_method = "#{config[:column]}_sequence"

        scope = klass.where(config[:column] => @instance.send(base_method), sequence_method => @instance.send(sequence_method))
        scope = scope.where("#{klass.quoted_table_name}.#{klass.primary_key} <> ?", @instance.id) if @instance.persisted?

        !scope.exists?
      end


      def next_valid_slug_from_table
        base_field = config[:column]
        sequ_field = "#{config[:column]}_sequence"

        scope = klass.where(base_field => slug_base)
        scope = scope.where("#{klass.quoted_table_name}.#{klass.primary_key} <> ?", @instance.id) if @instance.persisted?

        "#{slug_base}--#{scope.maximum(sequ_field).to_i + 1}"
      end


      def next_valid_slug_from_history
        return nil unless config.option?(:history)

        scope = ::Louisville::Slug.where(:sluggable_type => ::Louisville::Util.polymorphic_name(klass))
        scope = scope.where(:slug_base => slug_base)
        scope = scope.where("#{Louisville::Slug.quoted_table_name}.sluggable_id <> ?", @instance.id) if @instance.persisted?

        "#{slug_base}--#{scope.maximum(:slug_sequence).to_i + 1}"
      end

    end

  end
end
