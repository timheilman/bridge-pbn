require 'spec_helper'

RSpec.describe Bridge::Suit do
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
      expect(result.map(&:class).uniq).to match_array [Bridge::Suit]
    end
  end

  describe ".card" do
    it "gives an array of suits" do
      result = described_class.card
      expect(result).to be_a Array
      expect(result.map(&:class).uniq).to match_array [Bridge::Suit]
    end

    it "does not include notrump" do
      expect(described_class.card).not_to include Bridge::Suit::NoTrump
    end
  end

  describe "#>" do
    described_class.all.each do |suit|
      context "with #{suit} as the reciever" do
        subject(:left) { suit }

        lower = all.take_while { |x| x != suit }.each do |right|
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
    described_class.all.each do |suit|
      context "with #{suit} as the reciever" do
        subject(:left) { suit }

        lower = (all.take_while { |x| x != suit } + [suit]).each do |right|
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
