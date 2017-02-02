module Bridge
  module Pbn
    module GameParserStates
      class InAuctionSection
        include GameParserState

        def process_char char
          parser.raise_error 'Auction sections are complicated and not yet implemented!'
        end
      end
    end
  end
end
