module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InAuctionSection < GameParserState
        def post_initialize
          @comments = []
          @calls = []
          @comment_array_for_last_token = @comments
          @is_completed = false
        end

        def single_char_to_method
          { semicolon => method(:start_semicolon_comment),
            open_curly => method(:start_curly_comment),
            equals_sign => method(:start_note_reference),
            asterisk => method(:handle_asterisk),
            plus_sign => method(:handle_plus_sign),
            open_bracket => method(:handle_open_bracket) }
        end

        def process_char(char)
          case char
          when whitespace_allowed_in_games then
            self
          when call_char then
            start_call char
          else
            handle_single_char char
          end
        end

        def handle_single_char(char)
          raise_error char unless single_char_to_method.include?(char)
          single_char_to_method[char].call
        end

        def raise_error(char)
          err_str = "Unexpected character within an auction section: `#{char}'"
          game_parser.raise_error err_str
        end

        def start_call(char)
          injector.game_parser_state(:InCall, self).process_char char
        end

        def handle_asterisk
          @is_completed = true
        end

        def handle_plus_sign
          @is_completed = false
        end

        def handle_open_bracket
          finalize
          injector.game_parser_state(:BeforeTagName)
        end

        def start_curly_comment
          raise_error open_curly unless commentary_permitted
          injector.game_parser_state(:InCurlyComment, self)
        end

        def start_semicolon_comment
          raise_error semicolon unless commentary_permitted
          injector.game_parser_state(:InSemicolonComment, self)
        end

        def add_comment(comment)
          @comment_array_for_last_token << comment
        end

        def start_note_reference
          injector.game_parser_state(:InNoteRef, self)
        end

        def finalize
          observer.with_auction_comments(@comments)
        end

        def finalize_after_note_references
          observer.with_auction(Api::Auction.new(@calls, @is_completed))
        end

        def with_call(call_string)
          @num_passes = 0 unless call_string == 'Pass'
          @num_passes += 1 if call_string == 'Pass'
          @is_completed = true if call_string == 'AP' || @num_passes == 3
          @calls << Api::AnnotatedCall.new(call_string, nil, [])
          @comment_array_for_last_token = @calls.last.comments
          @annotation_steward = AuctionAnnotationSteward.new(
            game_parser: game_parser, call: @calls.last, special_section: self, call_index: @calls.length - 1
          )
        end

        def with_suffix_annotation(suffix_annotation_string)
          @comment_array_for_last_token = @annotation_steward.with_suffix_annotation suffix_annotation_string
        end

        def with_note_reference_number(note_reference_number)
          @comment_array_for_last_token = @annotation_steward.with_note_reference_number note_reference_number
        end

        def with_auction_note(call_index, note_ref_text)
          @calls[call_index].annotation.note = note_ref_text
        end

        def commentary_permitted
          @section !~ non_whitespace
        end
      end
    end
  end
end
