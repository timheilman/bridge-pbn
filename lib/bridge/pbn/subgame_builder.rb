module Bridge
  module Pbn
    class SubgameBuilder
      attr_writer :section

      def clear
        @preceding_comments = []
        @tag_pair = []
        @following_comments = []
        @section = ''
      end

      def add_preceding_comment(comment)
        @preceding_comments << comment
      end

      def add_tag_item(tag_item)
        @tag_pair << tag_item
      end

      def tag_name
        @tag_pair[0]
      end

      def add_following_comment(comment)
        @following_comments << comment
      end

      def build
        Subgame.new(@preceding_comments, @tag_pair, @following_comments, @section)
      end
    end
  end
end
