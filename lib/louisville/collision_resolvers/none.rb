module Louisville
  module CollisionResolvers
    class None < Abstract

      def next_valid_slug
        @instance.louisville_slug
      end

    end
  end
end