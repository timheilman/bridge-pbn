require_relative 'subgame'
module PortableBridgeNotation
  module Internals
    class SubgameBuilder
      attr_writer :section

      def initialize
        clear
      end

      def clear
        @preceding_comments = []
        @tag_pair = []
        @following_comments = []
        @section = ''
        self
      end

      def add_preceding_comment(comment)
        @preceding_comments << comment
        self
      end

      def add_tag_item(tag_item)
        @tag_pair << tag_item
        self
      end

      def tag_name
        @tag_pair[0]
      end

      def add_following_comment(comment)
        @following_comments << comment
        self
      end

      def build
        subgame = Subgame.new(@preceding_comments, @tag_pair, @following_comments, @section)
        clear
        subgame
      end
    end
  end
end
