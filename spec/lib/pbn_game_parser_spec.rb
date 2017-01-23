require 'spec_helper'

def setup_single_subgame(pbn_game_string, *subgame_fields)
  subject(:pbn_game_string) {
    pbn_game_string
  }
  Bridge::PbnSubgame.new(*subgame_fields)
end

def expect_first_yield_with_arg(expected_arg)
  expect do |block|
    described_class.new.each_subgame(pbn_game_string, &block)
  end.to yield_with_args(expected_arg)
end

RSpec.describe Bridge::PbnGameParser do
  # intent: to maximize human readability for complicated quoting situations, use constants for all difficult characters
  NEWLINE = "\n"
  TAB = "\t"
  BACKSLASH = '\\'
  DOUBLE_QUOTE = '"'
  describe('#each_subgame') do

    context('with an opening single-line comment alone') do
      expected_arg = setup_single_subgame("; just a comment#{NEWLINE}",
                                          [' just a comment'], [], [], '')
      it('provides a structure with opening comment, no tag, no following comment, and no section') do
        expect_first_yield_with_arg(expected_arg)
      end
    end

    context('with an opening multi-line comment followed by event tag on the same line') do
      expected_arg = setup_single_subgame(
          "  { multiline #{NEWLINE} comment } [TagName #{DOUBLE_QUOTE}TagValue#{DOUBLE_QUOTE}]#{NEWLINE}",
          [" multiline #{NEWLINE} comment "], %w(TagName TagValue), [], '')
      it('provides a structure with the newline-containing comment, the tag pair, no following comment, no section') do
        expect_first_yield_with_arg(expected_arg)
      end
    end

    context('with a mixture of opening comments') do
      expected_arg = setup_single_subgame(
          ";one-liner#{NEWLINE}" +
              "{{{;;;multiline #{NEWLINE}" +
              "comment} ;with more commentary#{NEWLINE} " +
              " [TagName #{DOUBLE_QUOTE}TagValue#{DOUBLE_QUOTE}]#{NEWLINE}",
          ['one-liner', "{{;;;multiline #{NEWLINE}comment", 'with more commentary'],
          %w(TagName TagValue), [], '')
      it('provides multiple comments in the structure') do
        expect_first_yield_with_arg(expected_arg)
      end
    end

    context('with double-quotes in the tag value') do
      expected_arg = setup_single_subgame(
          "[TagName #{DOUBLE_QUOTE}Tag#{BACKSLASH}#{DOUBLE_QUOTE}Value#{DOUBLE_QUOTE}]",
          [], %w(TagName Tag"Value), [], '')
      it('handles escaped double-quotes properly') do
        expect_first_yield_with_arg(expected_arg)
      end
    end

    context('with backslash in the tag value') do
      expected_arg = setup_single_subgame("[TagName #{DOUBLE_QUOTE}Tag#{BACKSLASH}#{BACKSLASH}Value#{DOUBLE_QUOTE}]",
                                          [], ['TagName', "Tag#{BACKSLASH}Value"], [], '')
      it('handles escaped backslashes properly') do
        expect_first_yield_with_arg(expected_arg)
      end
    end

    context('with no comments, one tag pair, and a section') do
      expected_arg = setup_single_subgame("[TagName #{DOUBLE_QUOTE}TagValue#{DOUBLE_QUOTE}]#{NEWLINE}" +
                                              "three section tokens#{DOUBLE_QUOTE}and a string#{DOUBLE_QUOTE}#{NEWLINE}",
                                          [], %w(TagName TagValue), [],
                                          "three section tokens#{DOUBLE_QUOTE}and a string#{DOUBLE_QUOTE}#{NEWLINE}")
      it('yields the tag pair and the section unprocessed, including quotes and newlines') do
        expect_first_yield_with_arg(expected_arg)
      end
    end

    context('with comment before, one tag pair, comment after, and a section') do
      expected_arg = setup_single_subgame(
          ";comment1#{NEWLINE}" +
              "[TagName \"TagValue\" ]#{TAB}#{NEWLINE}" +
              "{comment2#{NEWLINE}" +
              "comment2 second line}#{NEWLINE}" +
              "verbatim section#{NEWLINE}",
          ['comment1'],
          %w(TagName TagValue),
          ["comment2#{NEWLINE}comment2 second line"],
          "verbatim section#{NEWLINE}")
      it('yields the single complete record accurately') do
        expect_first_yield_with_arg(expected_arg)
      end
    end

    context('with two very simple tag pairs') do
      subject(:pbn_game_string) { "[Event #{DOUBLE_QUOTE}#{DOUBLE_QUOTE}]#{NEWLINE}[Site #{DOUBLE_QUOTE}#{DOUBLE_QUOTE}]" }
      it('yields twice with the minimal structures') do
        expect do |block|
          described_class.new.each_subgame(pbn_game_string, &block)
        end.to yield_successive_args(Bridge::PbnSubgame.new([], ['Event', ''], [], ''),
                                     Bridge::PbnSubgame.new([], ['Site', ''], [], ''))
      end
    end

    context('with two very simple tag pairs with comments') do
      subject(:pbn_game_string) { ";preceding comment#{NEWLINE}" +
          "[Event #{DOUBLE_QUOTE}#{DOUBLE_QUOTE}] {comment following event} [Site #{DOUBLE_QUOTE}#{DOUBLE_QUOTE}] " +
          ";comment following site#{NEWLINE}" }
      it('yields twice with the structures including their commentary') do
        expect do |block|
          described_class.new.each_subgame(pbn_game_string, &block)
        end.to yield_successive_args(Bridge::PbnSubgame.new(['preceding comment'], ['Event', ''],
                                                                        ['comment following event'], ''),
                                     Bridge::PbnSubgame.new([], ['Site', ''],
                                                                        ['comment following site'], ''))
      end
    end

    context('with two very simple tag pairs with comments and sections') do
      subject(:pbn_game_string) { "{a1};a2#{NEWLINE}" +
          "[a3 \"\"] {a4} \"a5\" [b1 \"\"] ;b2 #{NEWLINE}" +
          "b3 b4#{NEWLINE}" +
          "b5 b6#{NEWLINE}" }
      it('yields twice with the structures including their commentary and section data') do
        expect do |block|
          described_class.new.each_subgame(pbn_game_string, &block)
        end.to yield_successive_args(Bridge::PbnSubgame.new(%w(a1 a2), ['a3', ''], ['a4'], '"a5" '),
                                     Bridge::PbnSubgame.new([], ['b1', ''], ['b2 '],
                                                                        "b3 b4#{NEWLINE}b5 b6#{NEWLINE}"))
      end
    end
  end
end
