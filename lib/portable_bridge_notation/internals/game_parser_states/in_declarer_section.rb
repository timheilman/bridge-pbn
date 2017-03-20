module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InDeclarerSection < VacuousSection
        def finalize
          emit_comments
          observer.with_declarer(Api::Declarer.new(tag_value[tag_value.length - 1],
                                                   !(tag_value !~ /^\^/)))
        end
      end
    end
  end
end
