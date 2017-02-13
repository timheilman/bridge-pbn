require_relative 'outside_tag_and_section_template'
module PortableBridgeNotation::GameParserStates
  class BeforeFirstTag < OutsideTagAndSectionTemplate
    def add_comment(comment)
      builder.add_preceding_comment comment
    end

    def perhaps_yield
      #no-op
    end

    def section_tokens_allowed?
      false
    end
  end
end
