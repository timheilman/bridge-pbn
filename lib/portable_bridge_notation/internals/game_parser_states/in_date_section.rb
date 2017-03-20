module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InDateSection < VacuousSection
        def finalize
          emit_comments
          year, month, day = tag_value.match(
            /([0-9?][0-9?][0-9?][0-9?])\.([0-9?][0-9?])\.([0-9?][0-9?])/
          ).captures
          observer.with_date Api::Date.new(year, month, day)
        end
      end
    end
  end
end
