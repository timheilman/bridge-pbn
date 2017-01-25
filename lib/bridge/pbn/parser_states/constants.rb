module Bridge
  module Pbn
    module ParserConstants
      ALLOWED_WHITESPACE_CHARS = /[ \t\v\r\n]/
      SEMICOLON = ';'
      NEWLINE_CHARACTERS = "\n" # TODO: make this configurable to be less Mac-centric; don't depend on single char
      OPEN_CURLY = '{'
      CLOSE_CURLY = '}'
      OPEN_BRACKET = '['
      SECTION_STARTING_TOKENS = /[^\[\]{\};%]/
      ALLOWED_NAME_CHARS = /[A-Za-z0-9_]/
      DOUBLE_QUOTE = '"'
      CLOSE_BRACKET = ']'
    end

    module ParserDelegate
      attr_reader :parser

      def initialize(parser)
        @parser = parser
      end
    end
  end
end
