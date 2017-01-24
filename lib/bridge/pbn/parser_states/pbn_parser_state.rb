module Bridge
  class PbnParserState
    def done? #override for single Done state
      false
    end
  end
end
