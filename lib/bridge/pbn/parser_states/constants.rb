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
      BACKSLASH = '\\'
      NOT_DOUBLE_QUOTE = /[^"]/
    end

    module ParserState
      attr_reader :parser
      attr_reader :next_state

      def initialize(parser, next_state = nil)
        @parser = parser
        @next_state = next_state
        if self.respond_to? :post_initialize
          post_initialize
        end
      end
    end
  end
end
