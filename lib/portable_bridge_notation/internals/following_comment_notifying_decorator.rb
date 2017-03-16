require 'active_support/inflector'
module PortableBridgeNotation
  module Internals
    class FollowingCommentNotifyingDecorator
      def initialize(observer:,
                     tag_name:,
                     subgame_parser:)
        @observer = observer
        @tag_name = tag_name
        @subgame_parser = subgame_parser
      end

      def parse(subgame)
        @subgame_parser.parse subgame
        comments_listener_method = 'with_' << @tag_name.underscore << '_comments'
        return if @tag_name == 'Note' || subgame.followingComments.nil?
        @observer.send(comments_listener_method, subgame.followingComments)
      end
    end
  end
end
