module PortableBridgeNotation::GameParserStates
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
