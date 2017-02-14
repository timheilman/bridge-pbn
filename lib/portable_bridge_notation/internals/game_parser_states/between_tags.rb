require_relative 'outside_tag_and_section_template'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class BetweenTags < OutsideTagAndSectionTemplate
        def add_comment(comment)
          mediator.add_following_comment comment
        end

        def perhaps_yield
          mediator.yield_subgame
        end

        def section_tokens_allowed?
          true
        end
      end
    end
  end
end
