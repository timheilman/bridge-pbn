module Bridge::Pbn::GameParserStates
  class InPlaySection
    include GameParserState

    def process_char(char)
      parser.raise_error 'Play sections are complicated and not yet implemented!'
    end
  end
end
