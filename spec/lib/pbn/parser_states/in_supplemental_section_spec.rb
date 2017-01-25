require 'spec_helper'

RSpec.describe Bridge::Pbn::InSupplementalSection do
  describe('#process_char') do
    let(:parser) { double }
    let(:described_object) { described_class.new(parser) }
    %w(] { } ; %).each do |disallowed_symbol|
      it("should raise an error for disallowed symbol #{disallowed_symbol}. " +
             'Bug with ] in comment remains, strings untreated.') do
        error = StandardError.new 'Mock error'
        error_regexp = Regexp.new(".*supplemental section.*.*#{disallowed_symbol}")
        expect(parser).to receive(:raise_error).with(match error_regexp).and_raise error
        expect { described_object.process_char(disallowed_symbol) }.to raise_error StandardError
      end
    end

  end

end
