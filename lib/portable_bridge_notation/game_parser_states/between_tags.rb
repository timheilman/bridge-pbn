module PortableBridgeNotation::GameParserStates
  class BetweenTags < OutsideTagAndSectionTemplate
    def add_comment(comment)
      domain_builder.add_following_comment comment
    end

    def perhaps_yield
      game_parser.yield_subgame
    end

    def section_tokens_allowed?
      true
    end
  end
end
