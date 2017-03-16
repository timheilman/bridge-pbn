module PortableBridgeNotation
  module Internals
    module SubgameParsers
      class BoardSubgameParser < SubgameParser
        def parse(subgame)
          @observer.with_board(Integer(subgame.tagPair[1]))
        end
      end
    end
  end
end
