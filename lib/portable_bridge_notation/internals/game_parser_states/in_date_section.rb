module PortableBridgeNotation
  module Internals
    module GameParserStates
      class SimpleDateSection < VacuousSection
        def finalize
          emit_comments
          date_match_data = tag_value.match(
            /([0-9?][0-9?][0-9?][0-9?])\.([0-9?][0-9?])\.([0-9?][0-9?])/
          )
          return if date_match_data.nil?
          year, month, day = date_match_data.captures
          notify_observer PortableBridgeNotation::Api::Date.new(year, month, day)
        end
      end
      class InDateSection < SimpleDateSection
        def notify_observer(date)
          observer.with_date date
        end
      end
      class InEventDateSection < SimpleDateSection
        def notify_observer(date)
          observer.with_event_date date
        end
      end
      class InUTCDateSection < SimpleDateSection
        def notify_observer(date)
          observer.with_utc_date date
        end
      end
    end
  end
end
