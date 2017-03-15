module PortableBridgeNotation
  module Internals
    module SubgameParsers
      class SubgameParser
        def initialize(injector:, observer:, game_parser:)
          @injector = injector
          @observer = observer
          @game_parser = game_parser
        end
      end
    end
  end
end
