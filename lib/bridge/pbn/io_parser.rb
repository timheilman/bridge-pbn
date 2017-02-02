module Bridge::Pbn
  class IoParser
    # see sections 2.4 "Escape Mechanism", 3 "Game layout", and 3.8 "Commentary"
    SEMI_EMPTY_LINE = /^[\t ]*\r?$/
    PBN_ESCAPED_LINE = /^%/ # see section 2.4; do not confuse with Commentary from section 3.8
    def self.each_game_string(io)
      return enum_for(:each_game_string, io) unless block_given?
      record = ''
      comment_is_open = false
      # unfortunately the spec requires Latin-1.  Internal processing, since record's encoding is UTF-8,
      # will be in UTF-8.  Export to PBN will need to set the encoding on the export IO back to ISO_8859_1
      io.set_encoding(Encoding::ISO_8859_1)
      io.each do |line|
        if comment_is_open
          record << line
        elsif line =~ PBN_ESCAPED_LINE
          # potential site for processing of future directives in exported PBN files from this project
          next
        elsif line =~ SEMI_EMPTY_LINE
          yield record
          record = ''
        else
          record << line
        end
        comment_is_open = ParserUtil.instance.comment_open_after_eol? line, comment_is_open
      end
      yield record unless record.empty?
    end
  end
end
