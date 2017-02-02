module Bridge::Pbn::GameParserStates
  class OutsideTagAndSectionTemplate
    include GameParserState

    def process_char(char)
      case char
        when whitespace_allowed_in_games
          return self
        when semicolon
          #todo: abstract-factory these news
          return InSemicolonComment.new(parser, builder, self)
        when open_curly
          return InCurlyComment.new(parser, builder, self)
        when open_bracket
          perhaps_yield
          return BeforeTagName.new(parser, builder)
        when initial_supplemental_section_char
          err_str = "Unexpected section element starting character (see PBN section 5.1) : `#{char}'"
          parser.raise_error(err_str) unless section_tokens_allowed?
          section_state = if builder.tag_name == 'Play'
                            InPlaySection.new(parser, builder)
                          elsif builder.tag_name == 'Auction'
                            InAuctionSection.new(parser, builder)
                          else
                            InSupplementalSection.new(parser, builder)
                          end
          return section_state.process_char char
        else
          err_str = "Unexpected char outside 33-126 or closing brace, closing bracket, or percent sign: `#{char}'"
          parser.raise_error err_str
      end
    end

    def finalize
      # no-op
    end

  end
end
