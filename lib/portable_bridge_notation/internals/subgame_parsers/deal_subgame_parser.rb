module PortableBridgeNotation
  module Internals
    module SubgameParsers
      class DealSubgameParser
        def initialize(abstract_factory, observer)
          @abstract_factory = abstract_factory
          @observer = observer
        end

        def parse(subgame)
          unless subgame.tagPair[0] == 'Deal'
            error_string = "Incorrect parser for subgame of tag #{subgame.tagPair[0]}; this parser is for Deal"
            raise @abstract_factory.make_error(error_string)
          end

          deal = subgame.tagPair[1]
          @abstract_factory.make_deal_string_parser(deal).yield_cards do |direction:, rank:, suit:|
            @domain_builder.with_dealt_card(direction: direction, rank: rank, suit: suit)
          end
        end
      end
    end
  end
end
