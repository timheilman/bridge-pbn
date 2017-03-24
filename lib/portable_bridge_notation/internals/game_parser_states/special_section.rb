module PortableBridgeNotation
  module Internals
    module GameParserStates
      class SpecialSection < GameParserState
        def post_initialize
          @comments = []
          @comment_array_for_last_token = @comments
          @is_completed = false
          @char_to_simple_enclosed_state = {
            open_curly => :InCurlyComment,
            semicolon => :InSemicolonComment,
            equals_sign => :InNoteRef,
            carat => :InIrregularity,
            dollar_sign => :InNag
          }
        end

        def process_char(char)
          return self if char =~ whitespace_allowed_in_games
          if @char_to_simple_enclosed_state.include? char
            injector.game_parser_state(@char_to_simple_enclosed_state[char], self)
          else
            handle_other_char char
          end
        end

        def handle_other_char(char)
          case char
          when special_section_token_char then start_special_section char
          when exclamation_point, question_mark then start_suffix char
          when asterisk then handle_asterisk
          when plus_sign then handle_plus_sign
          when open_bracket then handle_open_bracket
          end
        end

        def add_comment(comment)
          @comment_array_for_last_token << comment
        end

        def start_suffix(char)
          injector.game_parser_state(:InSuffix, self).process_char char
        end

        def with_suffix_annotation(suffix_annotation_string)
          @comment_array_for_last_token = @annotation_steward.with_suffix_annotation suffix_annotation_string
        end

        def with_nag(nag)
          @comment_array_for_last_token = @annotation_steward.with_nag nag
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
          # no-op: these sections are emitted separately by game_parser after note_references
        end
      end
    end
  end
end
