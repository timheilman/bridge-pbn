require_relative 'game_parser_state'

module PortableBridgeNotation::GameParserStates
  class BeforeTagValue < GameParserState

    def process_char(char)
      case char
        when whitespace_allowed_in_games
          return self
        when double_quote
          return state_factory.make_state(:InString, state_factory.make_state(:BeforeTagClose))
        else
          parser.raise_error "Unexpected non-whitespace, non-double quote character: `#{char}'"
      end
    end

    def finalize
      parser.raise_error 'end of input prior to tag value'
    end

  end
end
