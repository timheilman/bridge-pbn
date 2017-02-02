require 'spec_helper'

RSpec.describe Bridge::Pbn::GameParserStates::BeforeTagName do
  describe('#process_char') do
    let(:parser) { double }
    let(:builder) { double }
    let(:described_object) { described_class.new(parser, builder) }
    it('should skip whitespace') do
      expect(described_object.process_char("\t")).to be(described_object)
    end

    it('should raise an error for any non-whitespace and non-name token string') do
      expect(parser).to receive(:raise_error).with(match '.*whitespace.*name token.*;')
      described_object.process_char(';')
    end
  end

end
