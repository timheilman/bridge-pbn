module PortableBridgeNotation
  module Internals
    module SubgameParsers
      class DealSubgameParser < SubgameParser
        def parse(subgame)
          deal = subgame.tagPair[1]
          @injector.deal_string_parser(deal).yield_cards do |direction:, rank:, suit:|
            @observer.with_dealt_card(direction: direction, rank: rank, suit: suit)
          end
        end
      end
    end
  end
end
