module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InPlaySection < GameParserState
        def post_initialize
          @comments = []
        end

        def process_char(char)
          case char
          when open_bracket then handle_open_bracket
          when continuing_nonstring_supp_sect_char then handle_supp_section_char char
          when semicolon then handle_semicolon
          when open_curly then handle_open_curly
          else raise_error char
          end
          # future enclosed BetweenPlays states will be notifying this class of note refs, which then
          # need to head up to GameParserState#expect_play_ref_resolution
        end

        def raise_error(char)
          err_str = "Unexpected character within a supplemental section: `#{char}'"
          game_parser.raise_error err_str
        end

        def handle_supp_section_char(_char)
          self
        end

        def handle_open_bracket
          finalize
          injector.game_parser_state(:BeforeTagName)
        end

        def handle_open_curly
          raise_error open_curly unless commentary_permitted
          @section = ''
          return injector.game_parser_state(:InCurlyComment, self) if commentary_permitted
        end

        def handle_semicolon
          raise_error semicolon unless commentary_permitted
          @section = ''
          return injector.game_parser_state(:InSemicolonComment, self) if commentary_permitted
        end

        def add_comment(comment)
          @comments << comment
        end

        def finalize
          @section = '' unless @section =~ non_whitespace
          observer.with_play_comments(@comments)
          observer.with_play('Play was received but is section state only partly implemented')
        end

        def add_string(string)
          @section << double_quote
          @section << string
          @section << double_quote
        end

        def commentary_permitted
          @section !~ non_whitespace
        end
      end
    end
  end
end
