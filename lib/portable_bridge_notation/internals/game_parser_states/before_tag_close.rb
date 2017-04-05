require_relative 'game_parser_state'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class BeforeTagClose < GameParserState
        def post_initialize
          @tag_value = nil
        end

        attr_accessor :tag_value

        def process_char(char)
          case char
          when whitespace_allowed_in_games
            self
          when close_bracket
            enclosing_state.tag_value = tag_value if enclosing_state.respond_to? :tag_value=
            enclosing_state
          else
            game_parser.raise_error "Unexpected char other than whitespace or closing bracket: `#{char}'"
          end
        end

        def finalize
          game_parser.raise_error 'Unexpected unclosed tag.'
        end

        def add_string(string)
          self.tag_value = string
        end
      end
    end
  end
end
