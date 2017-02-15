require_relative '../single_char_comparison_constants'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class GameParserState
        include SingleCharComparisonConstants # DRYing the subclasses
        attr_reader :game_parser
        attr_reader :subgame_builder
        attr_reader :abstract_factory
        attr_reader :enclosing_state

        def initialize(game_parser:, subgame_builder:, abstract_factory:, enclosing_state:)
          @game_parser = game_parser
          @subgame_builder = subgame_builder
          @abstract_factory = abstract_factory
          @enclosing_state = enclosing_state
          post_initialize if respond_to? :post_initialize
        end
      end
    end
  end
end
