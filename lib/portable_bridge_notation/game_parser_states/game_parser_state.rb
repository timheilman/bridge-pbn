require_relative '../single_char_comparison_constants'
module PortableBridgeNotation::GameParserStates
  class GameParserState
    include PortableBridgeNotation::SingleCharComparisonConstants
    attr_reader :mediator

    def initialize(game_parser_state_mediator)
      @mediator = game_parser_state_mediator
      post_initialize if self.respond_to? :post_initialize
    end
  end
end