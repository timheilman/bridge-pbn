module Bridge::Pbn::GameParserStates
  class InString
    include GameParserState

    def post_initialize
      @string = ''
      @escaped = false
    end

    def process_char(char)
      case char
        when backslash
          @string << backslash if @escaped
          @escaped = !@escaped
        when double_quote
          if @escaped
            @escaped = false
            @string << double_quote
          else
            next_state.add_string(@string)
            return next_state
          end
        when tab, line_feed, vertical_tab, carriage_return
          parser.raise_error "PBN-valid but string-invalid ASCII control character. Decimal code point: #{char.ord}"
        else
          @escaped = false
          @string << char
      end
      self
    end

    def finalize
      parser.raise_error "end of input in unclosed string"
    end

  end
end
