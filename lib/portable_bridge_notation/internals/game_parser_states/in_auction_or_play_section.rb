require_relative 'in_section_template'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InAuctionOrPlaySection < InSectionTemplate
        def commentary_permitted
          true
        end
      end
    end
  end
end
