module Bridge
  module Pbn
    class BeforeTagClose
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

      def finalize
        parser.raise_error('Unexpected unclosed tag.')
      end
    end
  end
end