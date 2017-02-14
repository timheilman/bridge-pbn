require_relative '../single_char_comparison_constants'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class GameParserState
        include SingleCharComparisonConstants # DRYing the subclasses
        attr_reader :mediator

        def initialize(game_parser_state_mediator)
          @mediator = game_parser_state_mediator
          post_initialize if self.respond_to? :post_initialize
        end
      end
    end
  end
end
