module PortableBridgeNotation
  module Internals
    module GameParserStates
      class SimpleTimeSection < VacuousSection
        def finalize
          emit_comments
          hour, minute, second = tag_value.match(
            /([0-9?][0-9?]):([0-9?][0-9?]):([0-9?][0-9?])/
          ).captures
          notify_observer PortableBridgeNotation::Api::Time.new(Integer(hour), Integer(minute), Integer(second))
        end
      end
      class InTimeSection < SimpleTimeSection
        def notify_observer(time)
          observer.with_time time
        end
      end
      class InUTCTimeSection < SimpleTimeSection
        def notify_observer(time)
          observer.with_utc_time time
        end
      end
    end
  end
end
