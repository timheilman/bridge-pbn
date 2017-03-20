require_relative '../../../../../lib/portable_bridge_notation/internals/injector'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      module GameParserStateSpecHelper
        def make_testing_game_parser_state(described_class, pbn_game_string: nil, logger: nil, observer: nil)
          class_sym = described_class.name.split('::').last.to_sym
          factory = Injector.new
          factory.game_parser pbn_game_string, logger, observer
          factory.game_parser_state class_sym
        end
      end
    end
  end
end
