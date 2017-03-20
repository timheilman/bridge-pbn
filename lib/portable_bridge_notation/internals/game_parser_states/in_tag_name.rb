require_relative 'game_parser_state'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InTagName < GameParserState
        def post_initialize
          @tag_name = ''
        end

        def process_char(char)
          case char
          when allowed_in_names then
            handle_name_char char
          when whitespace_allowed_in_games then
            handle_whitespace
          when double_quote then
            handle_double_quote
          else
            game_parser.raise_error "non-whitespace, non-name character found ending tag name: #{char}"
          end
        end

        def handle_name_char(char)
          @tag_name << char
          self
        end

        def handle_whitespace
          make_next_state
        end

        def make_next_state
          far_future_section_state = safely_get_section_state
          near_future_before_tag_close_state = injector.game_parser_state(:BeforeTagClose, far_future_section_state)
          injector.game_parser_state(:BeforeTagValue, near_future_before_tag_close_state)
        end

        def safely_get_section_state
          section_state = injector.game_parser_state "In#{@tag_name}Section".to_sym
          section_state.tag_name = @tag_name if section_state.respond_to? :tag_name=
          section_state
        rescue NameError
          supplemental_section_state = injector.game_parser_state(:InUnrecognizedSupplementalSection)
          supplemental_section_state.tag_name = @tag_name
          supplemental_section_state
        end

        def handle_double_quote
          make_next_state.process_char double_quote
        end

        def finalize
          game_parser.raise_error 'end of input with unfinished tag name'
        end
      end
    end
  end
end
