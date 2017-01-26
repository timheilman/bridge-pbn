module Bridge
  module Pbn
    module GameParserState
      require 'bridge/pbn/constants'
      include ParserConstants
      attr_reader :parser
      attr_reader :next_state

      def initialize(parser, next_state = nil)
        @parser = parser
        @next_state = next_state
        if self.respond_to? :post_initialize
          post_initialize
        end
      end
    end
  end
end