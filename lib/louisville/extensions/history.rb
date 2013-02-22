module Louisville
  module Extensions
    module History

      def self.included(base)
        base.class_eval do

          has_many :historical_slugs, :class_name => 'Louisville::Slug', :dependent => :destroy

          after_save :generate_historical_slug, :if => :"#{louisville_config[:column]}_changed?"

          alias_method_chain :louisville_slug_unique?, :history
          alias_method_chain :prev_valid_louisville_slug, :history
        end
      end

      protected

      def generate_historical_slug
        previous_value = self.send("#{louisville_config[:column]}_was")
        self.historical_slugs.create(:slug => previous_value) if previous_value
      end
    end
  end
end
