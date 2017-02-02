module Bridge::Pbn::SubgameParsers
  class DealSubgameParser < Bridge::Handler
    def initialize(game_builder, successor)
      super(successor)
      @game_builder = game_builder
    end

    def handle(subgame)
      return defer(subgame) unless subgame.tagPair[0] == 'Deal'
      Bridge::Pbn::DealParser.deal(subgame.tagPair[1]).each do |hand|
        @game_builder.add_hand(Bridge::Hand.new hand)
      end
    end
  end
end
