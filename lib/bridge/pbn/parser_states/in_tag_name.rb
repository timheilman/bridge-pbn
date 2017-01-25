module Bridge
  module Pbn
    class InTagName < PbnParserState
      require 'bridge/pbn/parser_states/constants'
      include Bridge::Pbn::ParserConstants
      include Bridge::Pbn::ParserDelegate

      def process_chars
        tag_name = ''
        until parser.state == :done || parser.cur_char !~ ALLOWED_NAME_CHARS
          tag_name << parser.cur_char
          parser.inc_char
        end
        parser.add_tag_item tag_name
        parser.state = :beforeTagValue unless parser.state == :done
      end
    end
  end
end