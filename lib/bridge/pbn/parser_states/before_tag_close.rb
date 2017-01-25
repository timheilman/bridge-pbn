module Bridge
  module Pbn
    class BeforeTagClose < PbnParserState
      require 'bridge/pbn/parser_states/constants'
      include Bridge::Pbn::ParserConstants
      include Bridge::Pbn::ParserState

      def process_char char
        case char
          when ALLOWED_WHITESPACE_CHARS
            return self
          when CLOSE_BRACKET
            return BetweenTags.new(parser)
          else
            parser.raise_error "Unexpected char other than whitespace or closing bracket: `#{char}'"
        end
      end
    end
  end
end