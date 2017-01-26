module Bridge
  module Pbn
    class BeforeTagClose
      require 'bridge/pbn/game_parser_states/game_parser_state'
      include Bridge::Pbn::GameParserState

      def process_char char
        case char
          when ALLOWED_WHITESPACE_CHARS
            return self
          when CLOSE_BRACKET
            return BetweenTags.new(parser, builder)
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
end