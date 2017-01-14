require 'spec_helper'

RSpec.describe Bridge::Strain do
  all = %i{Club Diamond Heart Spade NoTrump}.map { |c| described_class.const_get c }

  describe ".new" do
    it "raises an error" do
      expect {
        described_class.new
      }.to raise_error NoMethodError
    end
  end

  describe ".all" do
    it "gives an array of suits" do
      result = described_class.all
      expect(result).to be_a Array
      expect(result.map(&:class).uniq).to match_array [Bridge::Strain]
    end
  end

  describe ".suits" do
    it "gives an array of suits" do
      result = described_class.suits
      expect(result).to be_a Array
      expect(result.map(&:class).uniq).to match_array [Bridge::Strain]
    end

    it "does not include notrump" do
      expect(described_class.suits).not_to include Bridge::Strain::NoTrump
    end
  end

  describe "#>" do
    described_class.all.each do |strain|
      context "with #{strain} as the receiver" do
        subject(:left) { strain }

        lower = all.take_while { |x| x != strain }.each do |right|
          it "is true for #{right}" do
            expect(left > right).to be true
          end
        end

        (all - lower).each do |right|
          it "is false for #{right}" do
            expect(left > right).to be false
          end
        end
      end
    end
  end

  describe "#<" do
    described_class.all.each do |strain|
      context "with #{strain} as the receiver" do
        subject(:left) { strain }

        lower = (all.take_while { |x| x != strain } + [strain]).each do |right|
          it "is false for #{right}" do
            expect(left < right).to be false
          end
        end

        (all - lower).each do |right|
          it "is true for #{right}" do
            expect(left < right).to be true
          end
        end
      end
    end
  end
end
