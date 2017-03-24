module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InVulnerableSection < VacuousSection
        def finalize
          emit_comments
          observer.with_vulnerable(value_to_send)
        end

        def value_to_send
          case tag_value
          when 'Love', '-' then
            'None'
          when 'Both' then
            'All'
          else
            safe_tag_value
          end
        end

        def safe_tag_value
          return tag_value if %w(None NS EW All).include? tag_value
          game_parser.raise_error "Unexpected vulnerability value: `#{tag_value}'"
        end
      end
    end
  end
end
