require_relative 'game_parser_state'
module PortableBridgeNotation::GameParserStates
  class BeforeTagClose < GameParserState
    def process_char char
      case char
        when whitespace_allowed_in_games
          return self
        when close_bracket
          return mediator.make_state :BetweenTags
        else
          mediator.raise_error "Unexpected char other than whitespace or closing bracket: `#{char}'"
      end
    end

    def finalize
      mediator.raise_error 'Unexpected unclosed tag.'
    end

    def add_string string
      mediator.add_tag_item(string)
    end
  end
end