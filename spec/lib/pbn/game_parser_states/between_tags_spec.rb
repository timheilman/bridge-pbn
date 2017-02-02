require 'spec_helper'

RSpec.describe Bridge::Pbn::GameParserStates::BetweenTags do
  describe('#process_char') do
    let(:parser) { double }
    let(:builder) { double }
    let(:described_object) { described_class.new(parser, builder) }
    let(:error) { StandardError.new 'Mock error' }

    it('should raise an error for closing brace, closing bracket, or percent sign') do
      error_regexp = /.*33.*126.*closing brace.*closing bracket.*percent sign.*\].*/
      expect(parser).to receive(:raise_error).with(error_regexp).and_raise error
      expect { described_object.process_char(']') }.to raise_error StandardError
    end

    it('should (presently) raise an error for Play and Auction sections') do
      %w(Play Auction).each do |string|
        allow(builder).to receive(:tag_name).and_return string
        expect(parser).to receive(:raise_error).with(Regexp.new(string)).and_raise error
        expect { described_object.process_char('S') }.to raise_error StandardError
      end
    end
  end

end
