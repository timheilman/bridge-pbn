require 'active_support/inflector'
module PortableBridgeNotation
  module Internals
    module SubgameParsers
      class SubgameParserForStringValue < SubgameParser
        def parse(subgame)
          @observer.send(('with_' << subgame.tagPair[0].underscore).to_sym, subgame.tagPair[1])
        end
      end
    end
  end
end
