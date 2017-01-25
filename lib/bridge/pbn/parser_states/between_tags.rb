module Bridge
  module Pbn
    class BetweenTags < OutsideTagAndSection
      def add_comment(comment)
        parser.add_following_comment comment
      end
    end
  end
end
