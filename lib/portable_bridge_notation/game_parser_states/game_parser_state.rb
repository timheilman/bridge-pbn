module PortableBridgeNotation::GameParserStates
  module GameParserState
    include PortableBridgeNotation::SingleCharComparisonConstants
    attr_reader :parser
    attr_reader :builder
    attr_reader :next_state

    #todo: apply Mediator and Builder patterns to eliminate triadic constructor
    def initialize(parser, builder, next_state = nil)
      @parser = parser
      @builder = builder
      @next_state = next_state
      if self.respond_to? :post_initialize
        post_initialize
      end
    end
  end
end