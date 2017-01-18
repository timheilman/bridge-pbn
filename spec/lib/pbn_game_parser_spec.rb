require 'spec_helper'

def setup_single_subgame(pbn_game_string, *subgame_fields)
  subject(:pbn_game_string) {
    pbn_game_string
  }
  Bridge::PbnGameParser::Subgame.new(*subgame_fields)
end

def expect_first_yield_with_arg(expected_arg)
  expect do |block|
    described_class.new.each_subgame(pbn_game_string, &block)
  end.to yield_with_args(expected_arg)
end

RSpec.describe Bridge::PbnGameParser do
  describe('#each_subgame') do

    context('with an opening single-line comment alone') do
      expected_arg = setup_single_subgame("; just a comment\n",
                                          [' just a comment'], [], [], [])
      it('yields control once') do
        expect { |block| described_class.new.each_subgame(pbn_game_string, &block) }.to yield_control.once
      end
      it('provides a structure with opening comment, no tag, no following comment, and no section') do
        expect_first_yield_with_arg(expected_arg)
      end
    end

    context('with an opening multi-line comment followed by event tag on the same line') do
      expected_arg = setup_single_subgame("  { this is a \nmultiline comment } [Event \"eventName\"]\n",
                                          [" this is a \nmultiline comment "], %w(Event eventName), [], [])
      it('yields control once') do
        expect do |block|
          described_class.new.each_subgame(pbn_game_string, &block)
        end.to yield_control.once
      end
      it('provides a structure with the newline-containing comment, the tag pair, no following comment, no section') do
        expect_first_yield_with_arg(expected_arg)
      end
    end

    context('with a mixture of opening comments') do
      expected_arg = setup_single_subgame(
          ";this is a single-line comment\n" +
              "{  { this is a \n" +
              "multiline comment } ;with more commentary\n"+
              " [Event \"eventName\"]\n",
          ['this is a single-line comment', "  { this is a \nmultiline comment ", 'with more commentary'],
          %w(Event eventName), [], [])
      it('provides multiple comments in the structure') do
        expect_first_yield_with_arg(expected_arg)
      end
    end

    context('with double-quotes in the event name') do
      expected_arg = setup_single_subgame(
          %.[Event "event \\"with a double quote"].,
          [], ['Event', 'event "with a double quote'], [], [])
      it('handles escaped double-quotes properly') do
        expect_first_yield_with_arg(expected_arg)
      end
    end

    context('with backslash in the event name') do
      expected_arg = setup_single_subgame(%.[Event "event \\\\with a backslash"].,
                                          [], ['Event', 'event \\with a backslash'], [], [])
      it('handles escaped backslashes properly') do
        expect_first_yield_with_arg(expected_arg)
      end
    end

    context('with no comments, one tag pair, and a section with only section tokens') do
      expected_arg = setup_single_subgame("[Event \"event\"]\nsome section tokens\n",
                                          [], %w(Event event), [], %w(some section tokens))
      it('yields the tag pair and the section tokens individually') do
        expect_first_yield_with_arg(expected_arg)
      end
    end
  end
end
