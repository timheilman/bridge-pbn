require_relative 'special_section'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InAuctionSection < SpecialSection
        def post_initialize
          super
          game_parser.reached_auction_section self
          @calls = []
        end

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
          observer.with_auction(Api::Auction.new(@calls, @is_completed))
          observer.with_auction_comments(@comments)
        end

        def with_special_section_token(call_string)
          return if call_string == hyphen
          compute_is_completed call_string
          @calls << Api::AnnotatedCall.new(call_string, nil, [])
          @comment_array_for_last_token = @calls.last.comments
          @annotation_steward = AuctionAnnotationSteward.new(
            game_parser: game_parser, call: @calls.last, special_section: self, call_index: @calls.length - 1
          )
        end

        def compute_is_completed(call_string)
          @num_passes = 0 unless call_string == 'Pass'
          @num_passes += 1 if call_string == 'Pass'
          @is_completed = true if call_string == 'AP' || @num_passes == 3
        end

        def with_auction_note(call_index, note_ref_text)
          @calls[call_index].annotation.note = note_ref_text
        end
      end
    end
  end
end
