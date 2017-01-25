require 'spec_helper'

class EventHandler < Bridge::Handler
  def initialize(successor, gameToBuild)
    super(successor)
    @gameToBuild = gameToBuild
  end

  def handle(subgame, &block)
    if subgame.tagPair[0] !~ /^Event$/
      defer(subgame, &block)
      return
    end
    @gameToBuild.setEvent('')
  end
end

RSpec.describe Bridge::Pbn::SubgameMarshaller do

  describe '#marshal' do
    let(:game_to_build) { double }
    before(:each) do
      allow(game_to_build).to receive(:setEvent)
    end

    it 'invokes the proper subgame handler' do
      marshaller = described_class.new(EventHandler.new(Bridge::ErrorRaisingHandler.new(nil), game_to_build))
      marshaller.marshal(Bridge::Pbn::Subgame.new([], ['Event', ''], [], ''))
      expect(game_to_build).to have_received(:setEvent).with('')
    end
  end
end
