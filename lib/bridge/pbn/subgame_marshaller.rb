module Bridge
  module Pbn
    class SubgameMarshaller < Bridge::Handler
      def initialize(successor)
        super(successor)
      end

      def marshal(subgame)
        defer(subgame)
      end
    end
  end
end