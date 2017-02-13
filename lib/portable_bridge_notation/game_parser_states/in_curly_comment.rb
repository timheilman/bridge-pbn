module PortableBridgeNotation::GameParserStates
  class InCurlyComment < GameParserState

    def post_initialize
      @comment = ''
    end

    def process_char(char)
      case char
        when close_curly
          mediator.add_comment(@comment)
          return mediator.next_state
        else
          @comment << char
          return self
      end
    end

    def finalize
      mediator.raise_error 'end of input within unclosed brace comment'
    end
  end
end
