require_relative 'outside_tag_and_section_template'
module PortableBridgeNotation::GameParserStates
  class BetweenTags < OutsideTagAndSectionTemplate
    def add_comment(comment)
      builder.add_following_comment comment
    end

    def perhaps_yield
      parser.yield_subgame
    end

    def section_tokens_allowed?
      true
    end
  end
end
