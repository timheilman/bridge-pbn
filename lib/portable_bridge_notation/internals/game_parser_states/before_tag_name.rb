require_relative 'game_parser_state'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class BeforeTagName < GameParserState
        def process_char(char)
          case char
            when whitespace_allowed_in_games
              return self
            when allowed_in_names
              return game_parser_factory.make_game_parser_state(:InTagName).process_char(char)
            else
              game_parser.raise_error "Unexpected non-whitespace, non-name token character: `#{char}'"
          end
        end

        def finalize
          game_parser.raise_error 'end of input prior to tag name'
        end

      end
    end
  end
end
