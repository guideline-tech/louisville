module Louisville
  module Extensions
    module History

      def self.included(base)
        base.class_eval do

          has_many :historical_slugs, :class_name => 'Louisville::Slug', :dependent => :destroy, :as => :sluggable

          after_save :delete_matching_historical_slug, :if => :louisville_slug_changed?
          after_save :generate_historical_slug, :if => :louisville_slug_changed?
        end
      end

      protected

      def delete_matching_historical_slug
        current_value = self.louisville_slug

        return unless current_value

        base, seq = Louisville::Util.slug_parts(current_value)

        self.historical_slugs.where(slug_base: base, slug_sequence: seq).delete_all
      end

      def generate_historical_slug
        previous_value = self.send("#{louisville_config[:column]}_was")

        return unless previous_value

        base, seq = Louisville::Util.slug_parts(previous_value)

        self.historical_slugs.create(:slug_base => base, :slug_sequence => seq)
      end
    end
  end
end
