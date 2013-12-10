module Louisville
  module Extensions
    module Collision

      def louisville_collision_resolver
        @louisville_collision_resolver ||= louisville_config.collision_resolver_class.new(self, louisville_config.options_for(:collision))
      end

    end
  end
end
