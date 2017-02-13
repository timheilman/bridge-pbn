require_relative 'subgame_parsers/deal_subgame_parser'
module PortableBridgeNotation
  class SubgameParserDispatcher
    def initialize(domain_builder, logger)
      @domain_builder = domain_builder
      @logger = logger
    end

    def handle(subgame)
      begin
        subgame_parser_class_for_tag_name = SubgameParsers.const_get(subgame.tagPair[0] + 'SubgameParser')
        subgame_parser_class_for_tag_name.new(@domain_builder).handle(subgame)
      rescue NameError
        @logger.warn("Unrecognized tag name; ignoring tag: #{subgame.tagPair[0]}")
      end
    end

  end

end
