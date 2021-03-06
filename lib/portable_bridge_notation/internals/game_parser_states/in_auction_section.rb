require_relative 'special_section'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InAuctionSection < SpecialSection
        def post_initialize
          super
          game_parser.reached_auction_section self
          @calls = []
          @skipped_player_count = 0
          @insufficient_but_accepted = false
        end
        attr_reader :calls
        attr_accessor :skipped_player_count
        attr_accessor :insufficient_but_accepted
        attr_accessor :num_passes

        def special_section_token_char
          call_char
        end

        def raise_error(char)
          err_str = "Unexpected character within an auction section: `#{char}'"
          game_parser.raise_error err_str
        end

        def start_special_section(char)
          injector.game_parser_state(:InCall, self).process_char char
        end

        def finalize_after_note_references
          observer.with_auction(Api::Auction.new(calls, is_completed))
          observer.with_auction_comments(comments)
        end

        def with_special_section_token(call_string)
          return if call_string == hyphen
          with_nonhyphen_special_section_token call_string
        end

        def with_nonhyphen_special_section_token(call_string)
          record_call call_string
          self.comment_array_for_last_token = calls.last.comments
          self.annotation_steward = AuctionAnnotationSteward.new(
            game_parser: game_parser, call: calls.last, special_section: self, call_index: calls.length - 1
          )
        end

        def record_call(call_string)
          compute_is_completed call_string
          calls << Api::AnnotatedCall.new(call_string, nil, sufficiency_get_and_reset, skip_count_get_and_reset, [])
        end

        def compute_is_completed(call_string)
          self.num_passes = 0 unless call_string == 'Pass'
          self.num_passes = num_passes + 1 if call_string == 'Pass'
          self.is_completed = true if call_string == 'AP' || num_passes == 3
        end

        def with_auction_note(call_index, note_ref_text)
          calls[call_index].annotation.note = note_ref_text
        end

        def with_insufficiency_irregularity
          self.insufficient_but_accepted = true
        end

        def with_skipped_player_irregularity
          self.skipped_player_count = skipped_player_count + 1
        end

        def sufficiency_get_and_reset
          to_return = insufficient_but_accepted
          self.insufficient_but_accepted = false
          to_return
        end

        def skip_count_get_and_reset
          to_return = skipped_player_count
          self.skipped_player_count = 0
          to_return
        end
      end
    end
  end
end
