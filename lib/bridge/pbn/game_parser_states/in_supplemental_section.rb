module Bridge::Pbn::GameParserStates
  class InSupplementalSection
    include GameParserState

    def post_initialize
      @section = ''
    end

    def process_char(char)
      # we are returning the section exactly as-provided, in order for custom supplemental sections
      # to be parsed in custom ways
      case char
        when open_bracket
          finalize
          parser.yield_subgame
          return BeforeTagName.new(parser, builder)
        when double_quote
          return InString.new(parser, builder, self)
        when continuing_nonstring_supp_sect_char
          @section << char
          return self
        else
          parser.raise_error "Unexpected character within a supplemental section: `#{char}'"
      end
    end

    def finalize
      builder.section = @section unless @section.empty?
    end

    def add_string(string)
      @section << double_quote
      @section << string
      @section << double_quote
    end
  end
end
