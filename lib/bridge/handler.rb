module Bridge
  class Handler
    attr_accessor :successor
    def initialize(successor)
      @successor = successor
    end
  end

  class EndOfChainError < StandardError
  end

  class ErrorRaisingHandler < Handler
    def handle(*args)
      raise EndOfChainError.new(
          'At end of the chain of responsibility, no object has handled the request. Args: ' + args.to_s)
    end
  end
end
