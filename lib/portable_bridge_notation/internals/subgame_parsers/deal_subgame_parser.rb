require_relative 'deal_string_parser'
module PortableBridgeNotation
  module Internals
    module SubgameParsers
      class DealSubgameParser
        def initialize(domain_builder, deal_string_parser_class:DealStringParser)
          @domain_builder = domain_builder
          @deal_string_parser_class = deal_string_parser_class
        end

        def parse(subgame)
          unless subgame.tagPair[0] == 'Deal'
            raise ArgumentError.new("Incorrect parser for subgame of tag #{subgame.tagPair[0]}; this parser is for Deal")
          end

          deal = subgame.tagPair[1]
          @deal_string_parser_class.new(deal).yield_cards do |direction:, rank:, suit:|
            @domain_builder.with_dealt_card(direction: direction, rank: rank, suit: suit)
          end
        end
      end
    end
  end
end
