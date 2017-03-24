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
        @in_auction_section_state = nil
        @in_play_section_state = nil
        @most_recent_special_section_state = nil
        @auction_note_ref_num_to_call_idxes = {}
        @play_note_ref_num_to_trick_idx_dir_pairs = {}
      end

      def parse
        state = @injector.game_parser_state :BeforeFirstTag
        @pbn_game_string.each_char.with_index do |char, index|
          @cur_char_index = index
          verify_char char
          # @logger.debug("State #{state.class} processing char '#{char}' at idx #{index}")
          state = state.process_char(char)
        end
        state.finalize
        @in_auction_section_state.finalize_after_note_references unless @in_auction_section_state.nil?
        @in_play_section_state.finalize_after_note_references unless @in_play_section_state.nil?
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

      def reached_auction_section(in_auction_section_state)
        @in_auction_section_state = in_auction_section_state
        @most_recent_special_section_state = in_auction_section_state
      end

      def reached_play_section(in_play_section_state)
        @in_play_section_state = in_play_section_state
        @most_recent_special_section_state = in_play_section_state
      end

      def expect_auction_ref_resolution(_in_auction_section_state, call_index, ref_num)
        @auction_note_ref_num_to_call_idxes[ref_num] = [] unless @auction_note_ref_num_to_call_idxes.key? ref_num
        @auction_note_ref_num_to_call_idxes[ref_num] << call_index
      end

      def expect_play_ref_resolution(in_play_section_state, trick_index, direction, ref_num)
        @in_play_section_state = in_play_section_state
        @play_note_ref_num_to_trick_idx_dir_pairs[ref_num] = [trick_index, direction]
      end

      def add_note_ref_resolution(ref_num, text)
        if @most_recent_special_section_state == @in_auction_section_state
          add_auction_note_ref_resolution ref_num, text
        else
          add_play_note_ref_resolution ref_num, text
        end
      end

      def add_play_note_ref_resolution(ref_num, text)
        err_string = "Note ref resolution #{ref_num} was provided (with text '#{text}'), "\
                       'but no play was expecting that resolution.'
        raise_error err_string unless @play_note_ref_num_to_trick_idx_dir_pairs.key? ref_num
        trick_idx_dir_pair = @play_note_ref_num_to_trick_idx_dir_pairs[ref_num]
        @in_play_section_state.with_play_note(trick_idx_dir_pair[0], trick_idx_dir_pair[1], text)
      end

      def add_auction_note_ref_resolution(ref_num, text)
        err_string = "Note ref resolution #{ref_num} was provided (with text '#{text}'), "\
                       'but no call was expecting that resolution.'
        raise_error err_string unless @auction_note_ref_num_to_call_idxes.key? ref_num
        @auction_note_ref_num_to_call_idxes[ref_num].each do |call_idx|
          @in_auction_section_state.with_auction_note(call_idx, text)
        end
      end
    end
  end
end
