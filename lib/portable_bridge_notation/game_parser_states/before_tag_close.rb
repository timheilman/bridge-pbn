module PortableBridgeNotation::GameParserStates
  class BeforeTagClose < GameParserState
    def process_char char
      case char
        when whitespace_allowed_in_games
          return self
        when close_bracket
          return state_factory.make_state(:BetweenTags)
        else
          parser.raise_error "Unexpected char other than whitespace or closing bracket: `#{char}'"
      end
    end

    def finalize
      parser.raise_error('Unexpected unclosed tag.')
    end

    def add_string string
      builder.add_tag_item(string)
    end
  end
end