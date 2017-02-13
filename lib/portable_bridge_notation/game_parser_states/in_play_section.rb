module PortableBridgeNotation::GameParserStates
  class InPlaySection < GameParserState

    def process_char(char)
      mediator.raise_error 'Play sections are complicated and not yet implemented!'
    end
  end
end
