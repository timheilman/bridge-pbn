require 'spec_helper'
require_relative '../../../lib/portable_bridge_notation/subgame'

RSpec.describe PortableBridgeNotation::Subgame do
  describe('#to_s') do
    let(:described_object) do
      PortableBridgeNotation::Subgame.new(['preceding comment'], %w(TagName TagValue), ['following comment'], 'section')
    end
    it 'should return some sensible string' do
      expect(described_object.to_s).to match(/preceding.*TagName.*TagValue.*following comment.*section/)
    end
  end
end