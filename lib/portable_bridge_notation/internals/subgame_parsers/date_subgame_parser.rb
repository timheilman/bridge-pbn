module PortableBridgeNotation
  module Internals
    module SubgameParsers
      class DateSubgameParser < SubgameParser
        def parse(subgame)
          year, month, day = subgame.tagPair[1].match(
            /([0-9?][0-9?][0-9?][0-9?])\.([0-9?][0-9?])\.([0-9?][0-9?])/
          ).captures
          @observer.with_date PortableBridgeNotation::Api::Date.new(year, month, day)
        end
      end
    end
  end
end
