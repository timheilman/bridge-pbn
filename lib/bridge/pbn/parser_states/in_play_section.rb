module Bridge
  module Pbn
    class InPlaySection < PbnParserState
      require 'bridge/pbn/parser_states/constants'
      include Bridge::Pbn::ParserConstants
      include Bridge::Pbn::ParserState

      def process_char(char)
        parser.raise_error 'Play sections are complicated and not yet implemented!'
      end
    end
  end
end
