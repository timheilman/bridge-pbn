module PortableBridgeNotation
  module Internals
    module GameParserStates
      class BeforeFirstTag < GameParserState
        def post_initialize
          @initial_comments = []
        end

        attr_reader :initial_comments

        def process_char(char)
          case char
          when whitespace_allowed_in_games then self
          when semicolon then injector.game_parser_state(:InSemicolonComment, self)
          when open_curly then injector.game_parser_state(:InCurlyComment, self)
          when open_bracket then handle_open_bracket
          else
            err_str = "Unexpected char other than whitespace, ';', '{', or '[' prior to any tag: `#{char}'"
            game_parser.raise_error err_str
          end
        end

        def handle_open_bracket
          finalize
          injector.game_parser_state(:BeforeTagName)
        end

        def finalize
          observer.with_initial_comments(initial_comments) unless initial_comments.empty?
        end

        def add_comment(comment)
          initial_comments << comment
        end
      end
    end
  end
end
