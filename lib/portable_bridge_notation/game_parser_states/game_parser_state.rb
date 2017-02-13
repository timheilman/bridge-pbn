require_relative '../single_char_comparison_constants'
module PortableBridgeNotation::GameParserStates
  class GameParserState
    include PortableBridgeNotation::SingleCharComparisonConstants
    attr_reader :mediator

    def initialize(game_parser_state_mediator)
      @mediator = game_parser_state_mediator
      if self.respond_to? :post_initialize
        post_initialize
      end
    end
  end
end