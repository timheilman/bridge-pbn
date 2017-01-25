module Bridge
  module Pbn
    class Done < PbnParserState
      def done?
        true
      end
    end
  end
end
