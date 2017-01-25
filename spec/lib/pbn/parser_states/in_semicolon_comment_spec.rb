require 'spec_helper'

RSpec.describe Bridge::Pbn::InSemicolonComment do
  describe('#process_char') do
    let(:parser) { double }
    let(:described_object) { described_class.new(parser) }
    context('with é provided in UTF-8 encoding') do
      let(:char) { 'é' }
      it('should allow the character') do
        expect(char.encoding).to be Encoding::UTF_8
        expect(described_object.process_char(char)).to be(described_object)
      end
    end
    context('with a form feed provided in UTF-8 encoding') do
      let(:char) { "\u000c" }
      it('should disallow the ASCII control character') do
        expect(char.encoding).to be Encoding::UTF_8
        expect { described_object.process_char(char) }.to raise_error(/.*disallowed.*: 12/)
      end
    end
    context('with a non-ASCII control character from ISO 8859/1') do
      let(:char) { 143.chr(Encoding::ISO_8859_1).encode(Encoding::UTF_8) }
      it('should disallow the character') do
        expect(char.encoding).to be Encoding::UTF_8
        expect { described_object.process_char(char) }.to raise_error(/.*disallowed.*: 143/)
      end
    end
  end
end
