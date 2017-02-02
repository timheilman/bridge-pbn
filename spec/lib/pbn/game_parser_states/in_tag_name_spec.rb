require 'spec_helper'

RSpec.describe Bridge::Pbn::GameParserStates::InTagName do
  describe('#process_char') do
    let(:parser) { double }
    let(:builder) { double }
    let(:described_object) { described_class.new(parser, builder) }

    %W(\t \n \v \r).each do |char|
      context("with PBN-permitted ASCII control code #{char.ord}") do
        it('should should disregard the character') do
          expect(builder).to receive(:add_tag_item)
          expect(described_object.process_char(char)).to be_a Bridge::Pbn::GameParserStates::BeforeTagValue
        end
      end
    end

    context('With iso 8859/1 character è') do
      it('should complain about it as an invalid character') do
        expect {described_object.process_char('è')}.to raise_error(/.*non-name character.*è.*/)
      end
    end
  end
end
