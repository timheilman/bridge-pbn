require_relative 'game_parser_state'

module PortableBridgeNotation::GameParserStates
  class BeforeTagName < GameParserState
    def process_char(char)
      case char
        when whitespace_allowed_in_games
          return self
        when allowed_in_names
          return state_factory.make_state(:InTagName).process_char(char)
        else
          parser.raise_error "Unexpected non-whitespace, non-name token character: `#{char}'"
      end
    end

    def finalize
      parser.raise_error 'end of input prior to tag name'
    end

  end
end