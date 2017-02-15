# require_relative 'single_char_comparison_constants' # is this needed? check after code movement to internals
require_relative 'game_parser_factory'
require_relative 'portable_bridge_notation_error'
module PortableBridgeNotation
  module Internals
    class GameParser
      include SingleCharComparisonConstants

      def initialize(pbn_game_string:,
                     subgame_builder:,
                     game_parser_state_factory_class: GameParserStates::GameParserFactory)
        @pbn_game_string = pbn_game_string
        @subgame_builder = subgame_builder
        @state = game_parser_state_factory_class.
            new(game_parser: self, subgame_builder: @subgame_builder).
            make_game_parser_state(:BeforeFirstTag)
        @section_notes = {}
      end

      # TODO: enforce section continuity (no identification section tags both before and after play/auction/supplemental)
      # TODO: enforce 255 char cap on line width
      def each_subgame(&block)
        @block = block
        @subgame_builder.clear
        process
      end

      def process
        @pbn_game_string.each_char.with_index do |char, index|
          @cur_char_index = index
          case (char.encode(Encoding::ISO_8859_1).ord)
            # intent: couldn't figure out how to do non-ascii by ordinal in a regexp; fell back to this
            # 9 is \t
            # 10 is \n
            # 11 is \v
            # 13 is \r
            # 32-126 are ASCII printable
            # 160-255 are non-ASCII printable
            when 0..8, 12, 14..31, 127..159
              raise_error "disallowed character in PBN files, decimal code: #{char.ord}"
          end
          @state = @state.process_char(char)
        end
        @state.finalize
        yield_subgame
      end

      def yield_subgame
        @block.yield @subgame_builder.build
        @subgame_builder.clear
      end

      def raise_error(message = nil)
        raise PortableBridgeNotationError.new("state: #{@state.to_s}; string: `#{@pbn_game_string}'; " +
                                                  "char_index: #{@cur_char_index.to_s}; message: #{message}")
      end

      def reached_section(section_name)
        @section_name = section_name
        @section_notes.merge! section_name => {}
      end

      # todo: to be called from NoteSubgameParser
      def add_note_ref_resolution(ref_num, text)
        @section_notes[@section_name].merge! ref_num => text
      end
    end
  end
end
