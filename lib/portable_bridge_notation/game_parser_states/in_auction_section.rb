module PortableBridgeNotation::GameParserStates
  class InAuctionSection < GameParserState

    def process_char char
      game_parser.raise_error 'Auction sections are complicated and not yet implemented!'
    end
  end
end
