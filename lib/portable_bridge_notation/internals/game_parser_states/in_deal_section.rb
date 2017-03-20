module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InDealSection < VacuousSection
        def finalize
          emit_comments
          injector.deal_string_parser(tag_value).yield_cards do |direction:, rank:, suit:|
            observer.with_dealt_card(direction: direction, rank: rank, suit: suit)
          end
        end
      end
    end
  end
end
