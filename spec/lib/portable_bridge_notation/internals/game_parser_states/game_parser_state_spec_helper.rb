require_relative '../../../../../lib/portable_bridge_notation/internals/injector'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      module GameParserStateSpecHelper
        def make_testing_game_parser_state(described_class)
          class_sym = described_class.name.split('::').last.to_sym
          factory = Injector.new subgame_builder
          factory.game_parser ''
          factory.game_parser_state class_sym
        end
      end
    end
  end
end
