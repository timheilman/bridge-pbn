require_relative 'outside_tag_and_section_template'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class BetweenTags < OutsideTagAndSectionTemplate
        def add_comment(comment)
          subgame_builder.add_following_comment comment
        end

        def perhaps_yield
          game_parser.yield_subgame
        end

        def section_tokens_allowed?
          true
        end
      end
    end
  end
end
