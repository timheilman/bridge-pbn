module Bridge
  module Pbn
    class InAuctionSection < PbnParserState
      require 'bridge/pbn/parser_states/constants'
      include Bridge::Pbn::ParserConstants
      include Bridge::Pbn::ParserState

      def process_chars
        parser.raise_exception 'Auction sections are complicated and not yet implemented!'
      end
    end
  end
end