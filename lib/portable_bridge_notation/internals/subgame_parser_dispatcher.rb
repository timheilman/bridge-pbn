# all subgame parsers implemented should be required here
require_relative 'subgame_parsers/deal_subgame_parser'
module PortableBridgeNotation
  module Internals
    class SubgameParserDispatcher
      def initialize(domain_builder, logger)
        @domain_builder = domain_builder
        @logger = logger
      end

      def parse(subgame)
        subgame_parser_class_for_tag_name = ''
        begin
          subgame_parser_class_for_tag_name = SubgameParsers.const_get(subgame.tagPair[0] + 'SubgameParser')
        rescue NameError
          @logger.warn("Unrecognized tag name; ignoring tag: #{subgame.tagPair[0]}")
          return
        end
        subgame_parser_class_for_tag_name.new(@domain_builder).parse(subgame)
      end

    end
  end
end
