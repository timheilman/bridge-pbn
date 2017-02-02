module Bridge::Pbn::GameParserStates
  class BeforeTagValue
    include GameParserState

    def process_char(char)
      case char
        when whitespace_allowed_in_games
          return self
        when double_quote
          return InString.new(parser, builder, BeforeTagClose.new(parser, builder))
        else
          parser.raise_error "Unexpected non-whitespace, non-double quote character: `#{char}'"
      end
    end

    def finalize
      parser.raise_error 'end of input prior to tag value'
    end

  end
end
