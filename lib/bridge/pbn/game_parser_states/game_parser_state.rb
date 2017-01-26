module Bridge
  module Pbn
    module GameParserState
      require 'bridge/pbn/constants'
      include ParserConstants
      attr_reader :parser
      attr_reader :builder
      attr_reader :next_state

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
end