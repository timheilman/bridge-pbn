module PortableBridgeNotation
  module Internals
    module GameParserStates
      class SpecialSection < GameParserState
        def post_initialize
          @comments = []
          @comment_array_for_last_token = @comments
          @is_completed = false
        end

        def process_char(char)
          case char
          when whitespace_allowed_in_games then
            self
          when special_section_token_char then
            start_special_section char
          else
            handle_single_char char
          end
        end

        def single_char_to_method
          { semicolon => method(:start_semicolon_comment),
            open_curly => method(:start_curly_comment),
            equals_sign => method(:start_note_reference),
            asterisk => method(:handle_asterisk),
            plus_sign => method(:handle_plus_sign),
            open_bracket => method(:handle_open_bracket) }
        end

        def handle_single_char(char)
          raise_error char unless single_char_to_method.include? char
          single_char_to_method[char].call
        end

        def start_curly_comment
          injector.game_parser_state(:InCurlyComment, self)
        end

        def start_semicolon_comment
          injector.game_parser_state(:InSemicolonComment, self)
        end

        def add_comment(comment)
          @comment_array_for_last_token << comment
        end

        def start_note_reference
          injector.game_parser_state(:InNoteRef, self)
        end

        def with_suffix_annotation(suffix_annotation_string)
          @comment_array_for_last_token = @annotation_steward.with_suffix_annotation suffix_annotation_string
        end

        def with_note_reference_number(note_reference_number)
          @comment_array_for_last_token = @annotation_steward.with_note_reference_number note_reference_number
        end

        def handle_asterisk
          @is_completed = true
          self
        end

        def handle_plus_sign
          @is_completed = false
          self
        end

        def handle_open_bracket
          finalize
          injector.game_parser_state(:BeforeTagName)
        end

        def finalize
          # no-op: these sections areemitted separately by game_parser after note_references
        end
      end
    end
  end
end
