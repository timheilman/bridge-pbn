module Bridge
  module Pbn
    module SubgameParsers
      class DealSubgameParser < Handler
        def initialize(game_builder, successor)
          super(successor)
          @game_builder = game_builder
        end

        def handle(subgame)
          if subgame.tagPair[0] != 'Deal'
            defer(subgame)
            return
          end
          DealParser.deal(subgame.tagPair[1]).each do |hand|
            @game_builder.add_hand(Hand.new hand)
          end
        end
      end
    end
  end
end
