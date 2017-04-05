module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InSuffix < GameParserState
        attr_accessor :suffix

        def post_initialize
          self.suffix = ''
        end

        def process_char(char)
          case char
          when exclamation_point, question_mark then
            suffix << char
            self
          else
            finalize
            enclosing_state.process_char char
          end
        end

        def finalize
          enclosing_state.with_suffix_annotation suffix
        end
      end
    end
  end
end
