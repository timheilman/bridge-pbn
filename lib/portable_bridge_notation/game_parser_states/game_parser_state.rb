require_relative '../single_char_comparison_constants'
module PortableBridgeNotation::GameParserStates
  class GameParserState
    include PortableBridgeNotation::SingleCharComparisonConstants
    attr_reader :game_parser
    attr_reader :domain_builder
    attr_reader :game_parser_state_factory
    attr_reader :next_state

    def initialize(game_parser_state_builder)
      @game_parser = game_parser_state_builder.game_parser
      @domain_builder = game_parser_state_builder.domain_builder
      @game_parser_state_factory = game_parser_state_builder.game_parser_state_factory
      @next_state = game_parser_state_builder.next_state
      if self.respond_to? :post_initialize
        post_initialize
      end
    end
  end
end