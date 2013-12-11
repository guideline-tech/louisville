#
# Enables the slug to be dictated by the instance.
module Louisville
  module Extensions
    module Setter

      def self.configure_default_options(options)
        options[:setter] = "desired_#{options[:column]}" if options[:setter] == true
      end

      def self.included(base)
        base.class_eval do
          attr_accessor :desired_louisville_slug
          alias_method :"#{louisville_config[:setter]}=", :desired_louisville_slug=

          if respond_to?(:accessible_attributes) && accessible_attributes.any?
            attr_accessible :desired_louisville_slug, louisville_config[:setter].to_sym
          end

          alias_method_chain :extract_louisville_slug_value_from_field, :setter
          alias_method_chain :should_uniquify_louisville_slug?, :setter

        end
      end

      protected

      def extract_louisville_slug_value_from_field_with_setter
        self.desired_louisville_slug || extract_louisville_slug_value_from_field_without_setter
      end

      def should_uniquify_louisville_slug_with_setter?
        return false if !!self.desired_louisville_slug
        self.should_uniquify_louisville_slug_without_setter?
      end

    end
  end
end
