module Bridge
  module Pbn
    class BeforeTagName < PbnParserState
      require 'bridge/pbn/parser_states/constants'
      include Bridge::Pbn::ParserConstants
      include Bridge::Pbn::ParserState

      def process_char(char)
        case char
          when ALLOWED_WHITESPACE_CHARS
            return self
          when ALLOWED_NAME_CHARS
            return InTagName.new(parser).process_char(char)
          else
            parser.raise_exception
        end
      end

    end
  end
end