require_relative 'game_parser_state'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InSectionTemplate < GameParserState
        def post_initialize
          @section = ''
        end

        def process_char(char)
          # we are returning the section exactly as-provided, in order for custom supplemental sections
          # to be parsed in custom ways
          case char
          when open_bracket then handle_open_bracket
          when double_quote then injector.game_parser_state(:InString, self)
          when continuing_nonstring_supp_sect_char then handle_supp_section_char char
          when semicolon then handle_semicolon
          when open_curly then handle_open_curly
          else
            raise_error char
          end
        end

        def raise_error(char)
          err_str = "Unexpected character within a supplemental section: `#{char}'"
          game_parser.raise_error err_str unless commentary_permitted
        end

        def handle_supp_section_char(char)
          @section << char
          self
        end

        def handle_open_bracket
          finalize
          game_parser.yield_subgame
          injector.game_parser_state(:BeforeTagName)
        end

        def handle_open_curly
          raise_error open_curly unless commentary_permitted
          @section << open_curly
          @closing_comment_char = '}'
          return injector.game_parser_state(:InCurlyComment, self) if commentary_permitted
        end

        def handle_semicolon
          raise_error semicolon unless commentary_permitted
          @section << semicolon
          @closing_comment_char = '\n'
          return injector.game_parser_state(:InSemicolonComment, self) if commentary_permitted
        end

        def add_comment(comment)
          @section << comment << @closing_comment_char
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
