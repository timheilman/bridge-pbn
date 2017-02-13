require_relative 'game_parser_state'

module PortableBridgeNotation::GameParserStates
  class OutsideTagAndSectionTemplate < GameParserState

    def process_char(char)
      case char
        when whitespace_allowed_in_games
          return self
        when semicolon
          return state_factory.make_state(:InSemicolonComment, self)
        when open_curly
          return state_factory.make_state(:InCurlyComment, self)
        when open_bracket
          perhaps_yield
          return state_factory.make_state(:BeforeTagName)
        when initial_supplemental_section_char
          err_str = "Unexpected section element starting character (see PBN section 5.1) : `#{char}'"
          parser.raise_error(err_str) unless section_tokens_allowed?
          section_state = if builder.tag_name == 'Play'
                            state_factory.make_state(:InPlaySection)
                          elsif builder.tag_name == 'Auction'
                            state_factory.make_state(:InAuctionSection)
                          else
                            state_factory.make_state(:InSupplementalSection)
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
