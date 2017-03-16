module PortableBridgeNotation
  module Internals
    module SubgameParsers
      class DeclarerSubgameParser < SubgameParser
        def parse(subgame)
          declarer_value = subgame.tagPair[1]
          @observer.with_declarer(PortableBridgeNotation::Api::Declarer.new(declarer_value[declarer_value.length - 1],
                                                                            !(declarer_value !~ /^\^/)))
        end
      end
    end
  end
end
