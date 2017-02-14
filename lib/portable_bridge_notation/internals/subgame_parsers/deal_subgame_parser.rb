require_relative '../deal_string_parser'
module PortableBridgeNotation
  module Internals
    module SubgameParsers
      class DealSubgameParser
        def initialize(domain_builder)
          @domain_builder = domain_builder
        end

        def parse(subgame)
          unless subgame.tagPair[0] == 'Deal'
            raise ArgumentError.new("Incorrect parser for subgame of tag #{subgame.tagPair[0]}; this parser is for Deal")
          end

          deal = subgame.tagPair[1]
          DealStringParser.new(deal).yield_cards do |direction: direction, rank: rank, suit: suit|
            @domain_builder.with_dealt_card(direction: direction, rank: rank, suit: suit)
          end
        end
      end
    end
  end
end
