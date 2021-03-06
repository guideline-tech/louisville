module Louisville
  module CollisionResolvers
    class StringSequence < Abstract


      def provides_collision_solution?
        true
      end


      def next_valid_slug
        provide_latest_slug(next_valid_slug_from_table, next_valid_slug_from_history)
      end



      protected



      def next_valid_slug_from_table
        length_command  = klass.connection.adapter_name =~ /sqlserver/i ? 'LEN' : 'LENGTH'
        pk_col          = "#{klass.quoted_table_name}.#{klass.primary_key}"
        col             = "#{klass.quoted_table_name}.#{config[:column]}"

        scope  = klass.select("#{col}")
        scope  = scope.where("#{col} = ? OR #{col} LIKE ?", slug_base, "#{slug_base}--%")
        scope  = scope.order("#{length_command}(#{col}) DESC, #{col} DESC")

        return nil unless record = scope.first

        next_slug(record.louisville_slug)
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
