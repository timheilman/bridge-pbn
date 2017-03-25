module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InTimeCallSection < VacuousSection
        def finalize
          emit_comments
          observer.with_time_call(Integer(tag_value))
        end
      end
    end
  end
end
