module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InBoardSection < VacuousSection
        def finalize
          emit_comments
          observer.with_board(Integer(tag_value))
        end
      end
    end
  end
end
