require_relative 'game_parser_state'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InAuctionSection < GameParserState
        def process_char(_char)
          game_parser.raise_error 'Auction sections are complicated and not yet implemented!'
        end
      end
    end
  end
end
