module Bridge
  module Pbn
    class InAuctionSection
      include GameParserState

      def process_char char
        parser.raise_error 'Auction sections are complicated and not yet implemented!'
      end
    end
  end
end
