module Bridge
  class BeforeFirstTag < PbnParserState
    require 'bridge/pbn/parser_states/constants'
    include Bridge::PbnParserConstants
    include Bridge::PbnParserDelegate

    def process_chars
      case parser.cur_char
        when ALLOWED_WHITESPACE_CHARS
          parser.inc_char
        when SEMICOLON
          parser.inc_char
          comment = ''
          while parser.cur_char != NEWLINE_CHARACTERS && parser.state != :done
            comment << parser.cur_char
            parser.inc_char
          end
          parser.add_comment(comment)
          parser.inc_char
        when OPEN_CURLY
          parser.inc_char
          comment = ''
          while parser.cur_char != CLOSE_CURLY && parser.state != :done
            comment << parser.cur_char
            parser.inc_char
          end
          parser.add_comment(comment)
          parser.inc_char
        when OPEN_BRACKET
          parser.state = :beforeTagName
          parser.inc_char
        when SECTION_STARTING_TOKENS
          raise_exception if parser.state == :beforeFirstTag
          parser.state = if parser.tag_name == 'Play'
                           :inPlaySection
                         elsif parser.tag_name == 'Auction'
                           :inAuctionSection
                         else
                           :inSupplementalSection
                         end
        else
          raise_exception
      end
    end

  end
end
