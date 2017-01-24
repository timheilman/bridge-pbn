module Bridge
  class BeforeTagValue < PbnParserState
    require 'bridge/pbn/parser_states/constants'
    include Bridge::PbnParserConstants
    include Bridge::PbnParserDelegate

    def process_chars
      case parser.cur_char
        when ALLOWED_WHITESPACE_CHARS
          parser.inc_char
        when DOUBLE_QUOTE
          parser.state = :inTagValue
          parser.inc_char
        else
          parser.raise_exception
      end
    end

  end
end
