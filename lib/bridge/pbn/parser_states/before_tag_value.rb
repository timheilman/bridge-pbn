module Bridge
  module Pbn
    class BeforeTagValue < PbnParserState
      require 'bridge/pbn/parser_states/constants'
      include Bridge::Pbn::ParserConstants
      include Bridge::Pbn::ParserState

      def process_char(char)
        case char
          when ALLOWED_WHITESPACE_CHARS
            return self
          when DOUBLE_QUOTE
            return InString.new(parser, BeforeTagClose.new(parser))
          else
            parser.raise_exception
        end
      end

    end
  end
end
