require_relative 'single_char_comparison_constants'
module PortableBridgeNotation
  module Internals
    class GameParser
      include SingleCharComparisonConstants

      def initialize(pbn_game_string:,
                     observer:,
                     injector:,
                     logger:)
        @pbn_game_string = pbn_game_string
        @observer = observer
        @injector = injector
        @section_notes = {}
        @logger = logger
      end

      def parse
        state = @injector.game_parser_state :BeforeFirstTag
        @pbn_game_string.each_char.with_index do |char, index|
          @cur_char_index = index
          verify_char char
          @logger.debug("State #{state.class} processing char '#{char}' at idx #{index}")
          state = state.process_char(char)
        end
        state.finalize
      end

      def verify_char(char)
        case char.encode(Encoding::ISO_8859_1).ord
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
      end

      def raise_error(message = nil)
        raise @injector.error("state: #{@state}; string: `#{@pbn_game_string}'; " \
                                                  "char_index: #{@cur_char_index}; message: #{message}")
      end

      def reached_section(section_name)
        @section_name = section_name
        @section_notes.merge! section_name => {}
      end

      def add_note_ref_resolution(ref_num, text)
        @section_notes[@section_name].merge! ref_num => text
      end

      def get_note_ref(ref_num)
        @section_notes[@section_name][ref_num]
      end
    end
  end
end
