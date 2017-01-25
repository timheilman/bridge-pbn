module Bridge
  module Pbn
    class BeforeFirstTag < OutsideTagAndSection
      def add_comment(comment)
        parser.add_preceding_comment comment
      end
    end
  end
end
