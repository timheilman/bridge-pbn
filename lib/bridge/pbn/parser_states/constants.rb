module Bridge
  module Pbn
    module ParserConstants
      EMPTY_REGEXP = //
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
      SECTION_INCLUDE_COMMENTS_BUGGY_HACK = /[^\[\]%]/
      PLAY_SECTION_TAG_NAME = 'Play'
      AUCTION_SECTION_TAG_NAME = 'Auction'
    end

    module ParserState
      attr_reader :parser
      attr_reader :last_state

      def initialize(parser, last_state = nil)
        @parser = parser
        @last_state = last_state
        if self.respond_to? :post_initialize
          post_initialize
        end
      end
    end
  end
end
