#
# The history extension stores previous slug values in the `slugs` table.
# It provides instances with a `historical_slugs` association that return Louisville::Slug records.
# Whenever a slug is changed the previous value is added to the table, the current value is never
# present in the history table.
#
# Provide `history: true` to your slug() invocation.
# No options are used.
#

module Louisville
  module Extensions
    module History


      def self.included(base)
        base.class_eval do

          # provide an association for easy lookup, joining, etc.
          has_many :historical_slugs, lambda { |klass|
            where(sluggable_type: Louisville::Util::polymorphic_name(klass.class))
          }, :class_name => 'Louisville::Slug', :dependent => :destroy, :foreign_key => :sluggable_id

          # If our slug has changed we should manage the history.
          after_save :delete_matching_historical_slug,  :if => :louisville_slug_changed?
          after_save :generate_historical_slug,         :if => :louisville_slug_changed?
        end
      end



      protected



      # First, we delete any previous slugs that this record owned that match the current slug.
      # This allows a record to return to a previous slug without duplication in the history table.
      def delete_matching_historical_slug
        current_value = self.louisville_slug

        return unless current_value

        base, seq = Louisville::Util.slug_parts(current_value)

        self.historical_slugs.where(:slug_base => base, :slug_sequence => seq).delete_all
      end


      # Then we generate a new historical slug for the previous value (if there is one).
      def generate_historical_slug
        previous_value = self.send("#{louisville_config[:column]}_was")

        return unless previous_value

        base, seq = Louisville::Util.slug_parts(previous_value)

        self.historical_slugs.create(:slug_base => base, :slug_sequence => seq)
      end
    end
  end
end
