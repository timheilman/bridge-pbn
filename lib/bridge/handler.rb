module Bridge
  class Handler
    def initialize(successor)
      @successor = successor
    end

    def defer(*args, &block)
      @successor.handle(*args, &block)
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
