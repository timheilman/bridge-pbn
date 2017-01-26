module Bridge
  module Pbn
    class InAuctionSection
      require 'bridge/pbn/game_parser_states/game_parser_state'
      include Bridge::Pbn::GameParserState

      def process_char char
        parser.raise_error 'Auction sections are complicated and not yet implemented!'
      end
    end
  end
end
