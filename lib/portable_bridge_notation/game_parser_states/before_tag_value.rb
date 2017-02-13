module PortableBridgeNotation::GameParserStates
  class BeforeTagValue < GameParserState

    def process_char(char)
      case char
        when whitespace_allowed_in_games
          return self
        when double_quote
          return game_parser_state_factory.make_state(:InString, game_parser_state_factory.make_state(:BeforeTagClose))
        else
          game_parser.raise_error "Unexpected non-whitespace, non-double quote character: `#{char}'"
      end
    end

    def finalize
      game_parser.raise_error 'end of input prior to tag value'
    end

  end
end
