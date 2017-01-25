module Bridge
  module Pbn
    class BeforeFirstTag < OutsideTagAndSection
      def add_comment(comment)
        parser.add_preceding_comment comment
      end
      def perhaps_yield
        #no-op
      end
      def section_tokens_allowed
        false
      end
    end
  end
end
