require 'spec_helper'

class ConcreteHandler < Bridge::Handler
  def initialize(successor, initialization_arg)
    super(successor)
    @initialization_arg = initialization_arg
  end

  def handle(handle_arg)
    handle_arg == @initialization_arg ? :requestHandledSuccessfully : defer(handle_arg)
  end
end

RSpec.describe Bridge::Handler do
  subject(:concreteHandler) { ConcreteHandler.new(Bridge::ErrorRaisingHandler.new(nil), :foo) }
  it 'should not need successor when first element of chain handles request' do
    expect(concreteHandler.handle(:foo)).to eq(:requestHandledSuccessfully)
  end
  it 'should raise an error when the first element of the chain cannot handle the request' do
    expect {concreteHandler.handle(:barbaz)}.to raise_error(Bridge::EndOfChainError, /no object has handled.*barbaz/)
  end
end

