module Bridge::Pbn::GameParserStates
  class InCurlyComment
    include GameParserState

    def post_initialize
      @comment = ''
    end

    def process_char(char)
      case char
        when close_curly
          next_state.add_comment(@comment)
          return next_state
        else
          @comment << char
          return self
      end
    end

    def finalize
      parser.raise_error 'end of input within unclosed brace comment'
    end
  end
end
