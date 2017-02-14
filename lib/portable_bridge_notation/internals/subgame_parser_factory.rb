# all subgame parsers implemented should be required here
require_relative 'subgame_parsers/deal_subgame_parser'
module PortableBridgeNotation
  module Internals
    class SubgameParserFactory
      def self.make_subgame_parser(domain_builder, tag_name)
        subgame_parser_class_for_tag_name = ''
        begin
          subgame_parser_class_for_tag_name = SubgameParsers.const_get(tag_name + 'SubgameParser')
        rescue NameError
          raise PortableBridgeNotationError.new "Unrecognized tag name: #{tag_name}"
        end
        subgame_parser_class_for_tag_name.new(domain_builder)
      end
    end
  end
end
