module Bridge
  module Pbn
    class BeforeTagName
      require 'bridge/pbn/game_parser_states/game_parser_state'
      include Bridge::Pbn::GameParserState

      def process_char(char)
        case char
          when ALLOWED_WHITESPACE_CHARS
            return self
          when ALLOWED_NAME_CHARS
            return InTagName.new(parser).process_char(char)
          else
            parser.raise_error "Unexpected non-whitespace, non-name token character: `#{char}'"
        end
      end

      def finalize
        parser.raise_error 'end of input prior to tag name'
      end

    end
  end
end