module Bridge
  module Pbn
    class PbnParserState
      def done? #override for single Done state
        false
      end
    end
  end
end
