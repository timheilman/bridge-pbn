module Bridge::Pbn
  class UnrecognizedSubgameHandler < Bridge::Handler
    def initialize logger
      super(nil)
      @logger = logger
    end

    def handle(subgame)
      @logger.warn("Unrecognized tag name: #{subgame.tagPair[0]}")
    end
  end
  class SubgameParserChainFactory
    def initialize(game_builder, logger)
      @game_builder = game_builder
      @logger = logger
    end

    def get_chain
      SubgameParsers::DealSubgameParser.new(@game_builder, UnrecognizedSubgameHandler.new(@logger))
    end
  end

end
