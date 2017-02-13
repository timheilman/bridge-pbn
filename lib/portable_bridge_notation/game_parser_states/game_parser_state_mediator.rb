module PortableBridgeNotation
  module GameParserStates
    class GameParserStateMediator
      def initialize(game_parser: game_parser,
                     subgame_builder: subgame_builder,
                     game_parser_state_factory: game_parser_state_factory,
                     next_state: next_state)
        @game_parser = game_parser
        @subgame_builder = subgame_builder
        @game_parser_state_factory = game_parser_state_factory
        @next_state = next_state
      end

      def add_preceding_comment(*args)
        @subgame_builder.add_preceding_comment *args
      end

      def add_tag_item(*args)
        @subgame_builder.add_tag_item *args
      end

      def add_following_comment(*args)
        @subgame_builder.add_following_comment *args
      end

      def tag_name
        @subgame_builder.tag_name
      end

      def section=(arg)
        @subgame_builder.section= arg
      end

      def make_state(*args)
        @game_parser_state_factory.make_state *args
      end

      def yield_subgame(*args)
        @game_parser.yield_subgame *args
      end

      def raise_error(*args)
        @game_parser.raise_error *args
      end

      def reached_section(*args)
        @game_parser.reached_section *args
      end

      def add_note_ref_resolution(*args)
        @game_parser.add_note_ref_resolution *args
      end

      def add_comment(*args)
        @next_state.add_comment *args
      end

      def add_string(*args)
        @next_state.add_string *args
      end

      def next_state
        @next_state
      end
    end
  end
end
