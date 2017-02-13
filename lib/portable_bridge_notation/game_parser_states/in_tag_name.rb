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
          domain_builder.add_tag_item(@tag_name)
          return game_parser_state_factory.make_state(:BeforeTagValue)
        when double_quote
          domain_builder.add_tag_item(@tag_name)
          return game_parser_state_factory.make_state(:InString, game_parser_state_factory.make_state(:BeforeTagClose))
        else
          game_parser.raise_error "non-whitespace, non-name character found ending tag name: #{char}"
      end
    end

    def finalize
      game_parser.raise_error 'end of input with unfinished tag name'
    end
  end
end
