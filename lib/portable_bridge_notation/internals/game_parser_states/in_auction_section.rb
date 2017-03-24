module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InAuctionSection < GameParserState
        def post_initialize
          @comments = []
          @calls = []
          @comment_array_for_last_token = @comments
          @is_completed = nil
          @is_in_progress = nil
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
          when whitespace_allowed_in_games then self
          when call_char then start_call char
          else handle_single_char char
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
          @is_in_progress = true
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
          observer.with_auction(Api::Auction.new(@calls, @is_completed, @is_in_progress))
        end

        def with_call(call_string)
          @calls << Api::AnnotatedCall.new(call_string, nil, [])
          @comment_array_for_last_token = @calls.last.comments
        end

        def with_suffix_annotation(suffix_annotation_string)
          with_nag(nag_string_for_suffix_annotation_string(suffix_annotation_string))
        end

        def nag_string_for_suffix_annotation_string(suffix_annotation_string)
          suffix_nag_indexes = { '!' => 1, '?' => 2, '!!' => 3, '??' => 4, '!?' => 5, '?!' => 6 }
          unless suffix_nag_indexes.include? suffix_annotation_string
            game_parser.raise_error "Unexpected suffix annotation string #{suffix_annotation_string}"
          end
          suffix_nag_indexes[suffix_annotation_string]
        end

        def with_note_reference_number(note_reference_number)
          annotation = make_or_get_annotation
          game_parser.expect_auction_ref_resolution(self, @calls.length - 1, note_reference_number)
          @comment_array_for_last_token = annotation.note_comments
        end

        def with_nag(nag_string)
          annotation = make_or_get_annotation
          annotation.commented_numeric_annotation_glyphs <<
            Api::CommentedNumericAnnotationGlyph.new(Integer(nag_string), [])
          @comment_array_for_last_token = annotation.commented_numeric_annotation_glyphs.last.comments
        end

        def with_auction_note(call_index, note_ref_text)
          @calls[call_index].annotation.note = note_ref_text
        end

        def make_or_get_annotation
          last_call = @calls.last
          last_call.annotation = Api::Annotation.new(nil, [], [], []) if last_call.annotation.nil?
          last_call.annotation
        end

        def commentary_permitted
          @section !~ non_whitespace
        end
      end
    end
  end
end
