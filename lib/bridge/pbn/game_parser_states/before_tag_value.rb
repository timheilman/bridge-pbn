module Bridge
  module Pbn
    class BeforeTagValue
      require 'bridge/pbn/game_parser_states/game_parser_state'
      include Bridge::Pbn::GameParserState

      def process_char(char)
        case char
          when ALLOWED_WHITESPACE_CHARS
            return self
          when DOUBLE_QUOTE
            return InString.new(parser, BeforeTagClose.new(parser))
          else
            parser.raise_error "Unexpected non-whitespace, non-double quote character: `#{char}'"
        end
      end

      def finalize
        parser.raise_error 'end of input prior to tag value'
      end

    end
  end
end
