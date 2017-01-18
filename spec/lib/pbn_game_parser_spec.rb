require 'spec_helper'

RSpec.describe Bridge::PbnGameParser do
  describe('#each_subgame') do

    context('with an opening single-line comment alone') do
      subject(:pbn_game_string) { "; just a comment\n" }
      it('yields control once') do
        expect { |block| described_class.new.each_subgame(pbn_game_string, &block) }.to yield_control.once
      end
      it('provides a structure with opening comment, no tag, no following comment, and no section') do
        expect do |block|
          described_class.new.each_subgame(pbn_game_string, &block)
        end.to yield_with_args(Bridge::PbnGameParser::Subgame.new([' just a comment'], [], [], nil))
      end
    end

    context('with an opening multi-line comment followed by event tag on the same line') do
      subject(:pbn_game_string) { "  { this is a \nmultiline comment } [Event \"eventName\"]\n" }
      expected_arg = Bridge::PbnGameParser::Subgame.new(
          [" this is a \nmultiline comment "], %w(Event eventName), [], nil)
      it('yields control once') do
        expect do |block|
          described_class.new.each_subgame(pbn_game_string, &block)
        end.to yield_control.once
      end
      it('provides a structure with the newline-containing comment, the tag pair, no following comment, no section') do
        expect do |block|
          described_class.new.each_subgame(pbn_game_string, &block)
        end.to yield_with_args(expected_arg)
      end
    end
    context('with a mixture of opening comments') do
      subject(:pbn_game_string) {
        ";this is a single-line comment\n  {  { this is a \nmultiline comment } ;with more commentary\n [Event \"eventName\"]\n" }
      expected_arg = Bridge::PbnGameParser::Subgame.new(
          ['this is a single-line comment', "  { this is a \nmultiline comment ", 'with more commentary'], %w(Event eventName), [], nil)
      it('provides multiple comments in the structure') do
        expect do |block|
          described_class.new.each_subgame(pbn_game_string, &block)
        end.to yield_with_args(expected_arg)
      end
    end
    context('with double-quotes in the event name') do
      subject(:pbn_game_string) {
        %.[Event "event \\"with a double quote"].
      }
      expected_arg = Bridge::PbnGameParser::Subgame.new(
          [], ['Event', 'event "with a double quote'], [], nil)
      it('handles escaped double-quotes properly') do
        expect do |block|
          described_class.new.each_subgame(pbn_game_string, &block)
        end.to yield_with_args(expected_arg)
      end
    end
  end
end
