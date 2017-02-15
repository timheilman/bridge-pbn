require_relative 'string_parser_util'

module PortableBridgeNotation
  module Internals
    class IoParser
      include StringParserUtil
      # see sections 2.4 "Escape Mechanism", 3 "Game layout", and 3.8 "Commentary"
      SEMI_EMPTY_LINE = /^[\t ]*\r?$/
      PBN_ESCAPED_LINE = /^%/ # see section 2.4; do not confuse with Commentary from section 3.8

      def initialize(io)
        @io = io
      end

      def each_game_string(&block)
        return enum_for(:each_game_string) unless block_given?
        self.record = ''
        self.comment_is_open = false
        # unfortunately the spec requires Latin-1.  Internal processing, since record's encoding is UTF-8,
        # will be in UTF-8.  Export to PBN will need to set the encoding on the export IO back to ISO_8859_1
        io.set_encoding(Encoding::ISO_8859_1)
        io.each do |line|
          process_line line, &block
        end
        yield record unless record.empty?
      end

      private

      attr_reader :io
      attr_accessor :record
      attr_accessor :comment_is_open

      def process_line(line, &block)
        if comment_is_open
          record << line
        elsif line =~ PBN_ESCAPED_LINE
          # potential site for processing of future directives in exported PBN files from this project
        elsif line =~ SEMI_EMPTY_LINE
          block.yield record
          self.record = ''
        else
          record << line
        end
        self.comment_is_open = comment_open_after_eol? line, comment_is_open
      end
    end
  end
end
