module PortableBridgeNotation::SubgameParsers
  class DealSubgameParser < PortableBridgeNotation::Handler
    def initialize(game_builder, successor)
      super(successor)
      @game_builder = game_builder
    end

    # todo: rejigger this, if we want to keep it, to query responds_to? from the outside, rather than deferring from inside
    def handle(subgame)
      return defer(subgame) unless subgame.tagPair[0] == 'Deal'
      deal = subgame.tagPair[1]
      PortableBridgeNotation::DealStringParser.new(deal).yield_cards do |direction: direction, rank: rank, suit: suit|
        @game_builder.with_dealt_card(direction: direction, rank: rank, suit: suit)
      end
    end
  end
end
