module PortableBridgeNotation
  module Internals
    module SubgameParsers
      class SubgameParser
        def initialize(abstract_factory:, observer:, game_parser:)
          @abstract_factory = abstract_factory
          @observer = observer
          @game_parser = game_parser
        end
      end
    end
  end
end
