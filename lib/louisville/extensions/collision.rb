#
# The collision extension handles collisions as part of the save process. It uses a CollisionResolver
# object to handle the heavy lifting.
#
# Provide `collision: true`, or `collision: :name_of_collision_resolver` to your slug() invocation.
# No options are used.
#

module Louisville
  module Extensions
    module Collision


      def self.configure_default_options(options)
        options[:collision] = :string_sequence if options[:collision] == true
      end


      def self.included(base)
        base.class_eval do
          alias_method_chain :louisville_slug,                  :resolver
          alias_method_chain :louisville_slug=,                 :resolver
          alias_method_chain :louisville_slug_changed?,         :resolver
          alias_method_chain :validate_louisville_slug,         :resolver

          before_validation :make_louisville_slug_unique, :if => :should_uniquify_louisville_slug?
        end
      end


      def louisville_slug_with_resolver
        louisville_collision_resolver.read_slug
      end



      protected



      def louisville_slug_with_resolver=(val)
        louisville_collision_resolver.assign_slug(val)
      end


      def louisville_slug_changed_with_resolver?
        louisville_collision_resolver.slug_changed?
      end


      def louisville_collision_resolver
        @louisville_collision_resolver ||= begin
          class_name  = louisville_config.options_for(:collision)[:resolver] || louisville_config[:collision]
          klass       = Louisville::CollisionResolvers.const_get(:"#{class_name.to_s.classify}")
          klass.new(self, louisville_config.options_for(:collision))
        end
      end


      def make_louisville_slug_unique
        return if louisville_collision_resolver.unique?

        self.louisville_slug = louisville_collision_resolver.next_valid_slug
      end


      def should_uniquify_louisville_slug?
        return false if louisville_config.option?(:setter) && desired_louisville_slug

        louisville_collision_resolver.provides_collision_solution? && louisville_slug_changed?
      end


      def validate_louisville_slug_with_resolver
        return false unless validate_louisville_slug_without_resolver

        unless louisville_collision_resolver.unique?
          self.errors.add(louisville_config[:column], :taken)
          return false
        end

        true
      end

    end
  end
end
