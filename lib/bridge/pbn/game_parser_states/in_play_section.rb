module Bridge
  module Pbn
    class InPlaySection
      require 'bridge/pbn/game_parser_states/game_parser_state'
      include Bridge::Pbn::GameParserState

      def process_char(char)
        parser.raise_error 'Play sections are complicated and not yet implemented!'
      end
    end
  end
end
