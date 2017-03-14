require_relative 'game_parser_state'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InSupplementalSection < GameParserState
        def post_initialize
          @section = ''
        end

        def process_char(char)
          # we are returning the section exactly as-provided, in order for custom supplemental sections
          # to be parsed in custom ways
          case char
          when open_bracket then handle_open_bracket
          when double_quote then abstract_factory.make_game_parser_state(:InString, self)
          when continuing_nonstring_supp_sect_char then handle_supp_section_char char
          else
            game_parser.raise_error "Unexpected character within a supplemental section: `#{char}'"
          end
        end

        def handle_supp_section_char(char)
          @section << char
          self
        end

        def handle_open_bracket
          finalize
          game_parser.yield_subgame
          abstract_factory.make_game_parser_state(:BeforeTagName)
        end

        def finalize
          subgame_builder.section = @section unless @section.empty?
        end

        def add_string(string)
          @section << double_quote
          @section << string
          @section << double_quote
        end
      end
    end
  end
end
