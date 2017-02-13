module PortableBridgeNotation::GameParserStates
  class InTagName < GameParserState

    def post_initialize
      @tag_name = ''
    end

    def process_char(char)
      case char
        when allowed_in_names
          @tag_name << char
          return self
        when whitespace_allowed_in_games
          builder.add_tag_item(@tag_name)
          return state_factory.make_state(:BeforeTagValue)
        when double_quote
          builder.add_tag_item(@tag_name)
          return state_factory.make_state(:InString, state_factory.make_state(:BeforeTagClose))
        else
          parser.raise_error "non-whitespace, non-name character found ending tag name: #{char}"
      end
    end

    def finalize
      parser.raise_error 'end of input with unfinished tag name'
    end
  end
end
