require_relative '../single_char_comparison_constants'
module PortableBridgeNotation::GameParserStates
  class GameParserState
    include PortableBridgeNotation::SingleCharComparisonConstants
    attr_reader :parser
    attr_reader :builder
    attr_reader :next_state
    attr_reader :state_factory

    #todo: apply Mediator and Builder patterns to eliminate polyadic constructor
    #todo: make next_state required and use it to fix the issue with states returning their successor
    def initialize(parser, domain_builder, state_factory, next_state = nil)
      @parser = parser
      @builder = domain_builder
      @state_factory = state_factory
      @next_state = next_state
      if self.respond_to? :post_initialize
        post_initialize
      end
    end
  end
end