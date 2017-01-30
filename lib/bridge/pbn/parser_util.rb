module Bridge
  module Pbn
    class ParserUtil
      include ParserConstants

      # intent: this same functionality will eventually be needed by PlaySubgameParser and AuctionSubgameParser
      def self.comment_open_after_eol?(line, comment_is_open)
        last_char = nil
        line.each_char do |char|
          # see section 3.8 "Commentary"
          if char == OPEN_CURLY && (last_char.nil? || last_char == SPACE)
            comment_is_open = true
          end
          if char == CLOSE_CURLY
            comment_is_open = false
          end
          last_char = char
        end
        return comment_is_open
      end

    end
  end
end
