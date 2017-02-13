require_relative '../handler'
require_relative '../deal_string_parser'
module PortableBridgeNotation::SubgameParsers
  class DealSubgameParser
    def initialize(domain_builder)
      @domain_builder = domain_builder
    end

    def handle(subgame)
      unless subgame.tagPair[0] == 'Deal'
        raise ArgumentError.new("Incorrect handler for subgame of tag #{subgame.tagPair[0]}; this handler is for Deal")
      end

      deal = subgame.tagPair[1]
      PortableBridgeNotation::DealStringParser.new(deal).yield_cards do |direction: direction, rank: rank, suit: suit|
        @domain_builder.with_dealt_card(direction: direction, rank: rank, suit: suit)
      end
    end
    end
  end
