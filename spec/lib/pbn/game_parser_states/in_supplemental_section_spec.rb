require 'spec_helper'

RSpec.describe Bridge::Pbn::GameParserStates::InSupplementalSection do
  describe('#process_char') do
    let(:parser) { double }
    let(:builder) { double }
    let(:described_object) { described_class.new(parser, builder) }
    %w(] { } ; %).each do |disallowed_symbol|
      it("should raise an error for disallowed symbol #{disallowed_symbol}. ") do
        error = StandardError.new 'Mock error'
        error_regexp = Regexp.new(".*supplemental section.*.*#{Regexp.escape(disallowed_symbol)}")
        expect(parser).to receive(:raise_error).with(match error_regexp).and_raise error
        expect { described_object.process_char(disallowed_symbol) }.to raise_error StandardError
      end
    end

  end

end
