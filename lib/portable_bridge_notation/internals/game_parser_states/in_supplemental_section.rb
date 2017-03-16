require_relative 'in_section_template'
module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InSupplementalSection < InSectionTemplate
        def commentary_permitted
          false
        end
      end
    end
  end
end
