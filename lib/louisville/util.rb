module Louisville
  class Util


    SLUG_MATCHER = /^(.+)--([\d]+)$/


    class << self

      def numeric?(id)
        Integer === id || !!(id.to_s =~ /^[\d]+$/)
      end


      def slug_base(compare)
        compare =~ SLUG_MATCHER
        $1 || compare
      end


      def slug_sequence(compare)
        compare =~ SLUG_MATCHER
        [$2.to_i, 1].max
      end


      def slug_parts(compare)
        [slug_base(compare), slug_sequence(compare)]
      end


      def polymorphic_name(klass)
        klass.base_class.sti_name
      end

    end

  end
end
