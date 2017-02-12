require 'singleton'
module PortableBridgeNotation
  class ParserUtil
    include Singleton
    include SingleCharComparisonConstants

    # intent: this same functionality will eventually be needed by PlaySubgameParser and AuctionSubgameParser
    # todo: thus, make it a mixin; the arity-2 method is less bad than having two separate impls
    def comment_open_after_eol?(line, comment_is_open)
      last_char = nil
      line.each_char do |char|
        # see section 3.8 "Commentary"
        if char == open_curly && (last_char.nil? || last_char == space)
          comment_is_open = true
        end
        if char == close_curly
          comment_is_open = false
        end
        last_char = char
      end
      comment_is_open
    end

  end
end
