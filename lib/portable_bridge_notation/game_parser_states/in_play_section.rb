require_relative 'game_parser_state'
module PortableBridgeNotation::GameParserStates
  class InPlaySection < GameParserState

    def process_char(char)
      parser.raise_error 'Play sections are complicated and not yet implemented!'
    end
  end
end
