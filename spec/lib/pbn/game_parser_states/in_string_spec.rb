require 'spec_helper'

RSpec.describe Bridge::Pbn::GameParserStates::InString do
  describe('#process_char') do
    let(:parser) { double }
    let(:builder) { double }
    let(:described_object) { described_class.new(parser, builder) }

    %W(\t \n \v \r).each do |char|
      context("with PBN-permitted ASCII control code #{char.ord}") do
        it('should raise an error since it is within a string') do
          expect(parser).to receive(:raise_error).with(match ".*ASCII control.*: #{char.ord}")
          described_object.process_char(char)
        end
      end
    end
  end
end
