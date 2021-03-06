require_relative 'single_char_comparison_constants'
module PortableBridgeNotation
  module Internals
    module StringParserUtil
      include SingleCharComparisonConstants

      # intent: this same functionality will eventually be needed by InPlaySection- and InAuctionSection-enclosed
      # GameParserStates, as well as IoParser, for the same reasons
      # intent: hold our nose at the arity-2 method, considering it's better than the alternatives of
      # duplicating the logic or placing it arbitrarily in the inheritance hierarchy
      def comment_open_after_eol?(line, comment_is_open)
        last_char = nil
        line.each_char do |char|
          # see section 3.8 "Commentary"
          if char == open_curly && (last_char.nil? || last_char == space)
            comment_is_open = true
          end
          comment_is_open = false if char == close_curly
          last_char = char
        end
        comment_is_open
      end
    end
  end
end
