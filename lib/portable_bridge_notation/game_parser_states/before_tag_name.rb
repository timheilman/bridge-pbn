module PortableBridgeNotation::GameParserStates
  class BeforeTagName < GameParserState
    def process_char(char)
      case char
        when whitespace_allowed_in_games
          return self
        when allowed_in_names
          return mediator.make_state(:InTagName).process_char(char)
        else
          mediator.raise_error "Unexpected non-whitespace, non-name token character: `#{char}'"
      end
    end

    def finalize
      mediator.raise_error 'end of input prior to tag name'
    end

  end
end