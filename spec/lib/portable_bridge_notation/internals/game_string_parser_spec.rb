require 'spec_helper'
require_relative '../../../../lib/portable_bridge_notation/internals/single_char_comparison_constants'
require_relative '../../../../lib/portable_bridge_notation/internals/subgame'
require_relative '../../../../lib/portable_bridge_notation/internals/game_string_parser'
require_relative '../../../../lib/portable_bridge_notation/internals/game_parser_states/game_parser_state_factory'


module PortableBridgeNotation
  module Internals
    RSpec.describe GameStringParser do
      # todo: break this down, preserving every test case, to more closely focus on the edge case being tested
      # but do so against the specific GameParserState responsible to cover the case
      # intent: to maximize human readability for quoting situations, use bare words for all difficult characters
      include SingleCharComparisonConstants

      let(:expected_arg) { Subgame.new(*expected_subgame_fields) }

      def expect_first_yield_with_arg
        expect do |block|
          described_object.each_subgame(&block)
        end.to yield_with_args(expected_arg)
      end

      describe('#raise_error') do
        context 'when asked to raise an error' do
          let(:game_parser) { double }
          let(:subgame_builder) { double }
          let(:game_parser_state_factory) { double }
          let(:described_object) do
            temp = described_class.new subgame_builder: subgame_builder, pbn_game_string: ''
            temp.instance_variable_set(:@state, GameParserStates::GameParserStateFactory.
                new(game_parser, subgame_builder).make_state(:BeforeFirstTag))
            temp.instance_variable_set(:@cur_char_index, 17)
            temp
          end
          it 'Provides the state, char index, and given message' do
            expect { described_object.raise_error 'foobar' }.to raise_error(/.*BeforeFirstTag.*17.*foobar.*/)
          end
        end
      end

      describe('#each_subgame') do
        let(:described_object) { described_class.new(subgame_builder: SubgameBuilder.new,
                                                     pbn_game_string: pbn_game_string) }
        #### HAPPY PATHS #####

        context 'with an opening single-line comment with LF' do
          let(:pbn_game_string) { "; just a comment#{line_feed}" }
          let(:expected_subgame_fields) { [[' just a comment'], [], [], ''] }
          it 'provides a structure with opening comment, no tag, no following comment, and no section' do
            expect_first_yield_with_arg
          end
        end

        context 'with an opening multi-line comment followed by event tag on the same line' do
          let(:pbn_game_string) { "  { multiline #{line_feed}" +
              "comment } [TagName #{double_quote}TagValue#{double_quote}]#{line_feed}" }
          let(:expected_subgame_fields) { [[" multiline #{line_feed}comment "], %w(TagName TagValue), [], ''] }
          it 'provides a structure with the multi-line comment, the tag pair, no following comment, no section' do
            expect_first_yield_with_arg
          end
        end

        context 'with a mixture of opening comments' do
          let(:pbn_game_string) do
            ";one-liner#{line_feed}" +
                "{{{;;;multiline #{line_feed}" +
                "comment} ;with more commentary#{line_feed} " +
                " [TagName #{double_quote}TagValue#{double_quote}]#{line_feed}"
          end
          let(:expected_subgame_fields) { [['one-liner', "{{;;;multiline #{line_feed}comment", 'with more commentary'],
                                           %w(TagName TagValue), [], ''] }
          it 'provides multiple comments in the structure' do
            expect_first_yield_with_arg
          end
        end

        context 'with double-quotes in the tag value' do
          let(:pbn_game_string) { "[TagName #{double_quote}Tag#{backslash + double_quote}Value#{double_quote}]" }
          let(:expected_subgame_fields) { [[], %w(TagName Tag"Value), [], ''] }
          it 'handles escaped double-quotes properly' do
            expect_first_yield_with_arg
          end
        end

        context 'with tag value smooshed up against the tag name' do
          let(:pbn_game_string) { "[TagName#{double_quote}TagValue#{double_quote}]" }
          let(:expected_subgame_fields) { [[], %w(TagName TagValue), [], ''] }
          it "doesn't mind the absence of whitespace" do
            expect_first_yield_with_arg
          end
        end

        context 'with backslash in the tag value' do
          let(:pbn_game_string) { "[TagName #{double_quote}Tag#{backslash + backslash}Value#{double_quote}]" }
          let(:expected_subgame_fields) { [[], ['TagName', "Tag#{backslash}Value"], [], ''] }
          it 'handles escaped backslashes properly' do
            expect_first_yield_with_arg
          end
        end

        context 'with no comments, one tag pair, and a section' do
          let(:pbn_game_string) do
            "[TagName #{double_quote}TagValue#{double_quote}]#{line_feed}" +
                "three section tokens#{double_quote}and a string#{double_quote + line_feed}"
          end
          let(:expected_subgame_fields) do
            [[], %w(TagName TagValue), [],
             "three section tokens#{double_quote}and a string#{double_quote + line_feed}"]
          end
          it 'yields the tag pair and the section unprocessed, including quotes and newlines' do
            expect_first_yield_with_arg
          end
        end

        context 'with comment before, one tag pair, comment after, and a section' do
          let(:pbn_game_string) do
            ";comment1#{line_feed}" +
                "[TagName \"TagValue\" ]#{tab}#{line_feed}" +
                "{comment2#{line_feed}" +
                "comment2 second line}#{line_feed}" +
                "verbatim section#{line_feed}"
          end
          let(:expected_subgame_fields) do
            [['comment1'],
             %w(TagName TagValue),
             ["comment2#{line_feed}comment2 second line"],
             "verbatim section#{line_feed}"]
          end
          it 'yields the single complete record accurately' do
            expect_first_yield_with_arg
          end
        end

        context 'with two very simple tag pairs' do
          let(:pbn_game_string) { "[Event #{double_quote + double_quote}]#{line_feed}" +
              "[Site #{double_quote + double_quote}]" }
          it 'yields twice with the minimal structures' do
            expect do |block|
              described_object.each_subgame(&block)
            end.to yield_successive_args(Subgame.new([], ['Event', ''], [], ''),
                                         Subgame.new([], ['Site', ''], [], ''))
          end
        end

        context 'with two very simple tag pairs with comments' do
          let(:pbn_game_string) { ";preceding comment#{line_feed}" +
              "[Event #{double_quote + double_quote}] {comment following event} " + # no line_feed!
              "[Site #{double_quote + double_quote}] " +
              ";comment following site#{line_feed}" }
          it 'yields twice with the structures including their commentary' do
            expect do |block|
              described_object.each_subgame(&block)
            end.to yield_successive_args(Subgame.new(['preceding comment'], ['Event', ''],
                                                     ['comment following event'], ''),
                                         Subgame.new([], ['Site', ''],
                                                     ['comment following site'], ''))
          end
        end

        context 'with two very simple tag pairs with comments, sections, and CRLF line endings' do
          subject(:pbn_game_string) { "{a1};a2#{carriage_return + line_feed}" +
              "[a3 \"\"] {a4} \"a5\" [b1 \"\"] ;b2 #{carriage_return + line_feed}" +
              "b3 b4#{carriage_return + line_feed}" +
              "b5 b6#{carriage_return + line_feed}" }
          it 'yields twice with the structures including their commentary and section data' do
            expect do |block|
              described_object.each_subgame(&block)
            end.to yield_successive_args(Subgame.new(%w(a1 a2), ['a3', ''], ['a4'], '"a5" '),
                                         Subgame.new([], ['b1', ''], ['b2 '],
                                                     "b3 b4#{carriage_return + line_feed}" +
                                                         "b5 b6#{carriage_return + line_feed}"))
          end
        end

        ###### EDGE CASES #########

        context 'with an unclosed curly comment' do
          let(:pbn_game_string) { '{unclosed comment' }
          it 'complains about the unclosed comment' do
            expect { described_object.each_subgame {} }.to raise_error(/.*unclosed brace comment.*/)
          end
        end

        context 'with a semicolon comment closed by end-of-game' do
          let(:pbn_game_string) { '; comment without trailing newline' }
          let(:expected_subgame_fields) { [[' comment without trailing newline'], [], [], ''] }
          it 'treats end-of-game the same as end-of-line' do
            expect_first_yield_with_arg
          end
        end

        context 'with a barely-opened tag' do
          let(:pbn_game_string) { "[#{tab}#{tab}  " }
          it 'complains about the missing tag name' do
            expect { described_object.each_subgame {} }.to raise_error(/.*prior to tag name.*/)
          end
        end

        context 'with a tag name followed by end-of-game' do
          let(:pbn_game_string) { "[#{tab}#{tab}  TagName" }
          it 'complains about an unfinished tag name' do
            expect { described_object.each_subgame {} }.to raise_error(/.*unfinished tag name.*/)
          end
        end

        context 'with a tag name but no value' do
          let(:pbn_game_string) { "[#{tab + tab}  TagName " }
          it 'complains about the missing tag value' do
            expect { described_object.each_subgame {} }.to raise_error(/.*tag value.*/)
          end
        end

        context 'with an unclosed tag value' do
          let(:pbn_game_string) { "[#{tab + tab}  TagName #{double_quote}TagVal " }
          it 'complains about the unclosed string' do
            expect { described_object.each_subgame {} }.to raise_error(/.*unclosed string.*/)
          end
        end

        context 'with an unclosed tag' do
          let(:pbn_game_string) { "[TagName #{double_quote}TagValue#{double_quote}" }
          it 'complains about the unclosed tag' do
            expect { described_object.each_subgame {} }.to raise_error(/.*unclosed tag.*/)
          end
        end

        context 'with an opening single-line comment strangely containing two CRs then an LF' do
          let(:pbn_game_string) { "; just a comment#{carriage_return + carriage_return + line_feed}" }
          let(:expected_subgame_fields) { [[" just a comment#{carriage_return}"], [], [], ''] }
          it 'includes only the first CR in the string' do
            expect_first_yield_with_arg
          end
        end

        context 'with an opening single-line comment containing carriage_return in the middle of the string' do
          let(:pbn_game_string) { "; just a #{carriage_return}comment#{line_feed}" }
          let(:expected_subgame_fields) { [[" just a #{carriage_return}comment"], [], [], ''] }
          it 'includes the CR in the string' do
            expect_first_yield_with_arg
          end
        end

        context 'with printable latin-1 characters' do
          let(:pbn_game_string) { "; c'est très bon" }
          let(:expected_subgame_fields) { [[" c'est très bon"], [], [], ''] }
          it 'handles the latin-1 character just fine' do
            expect_first_yield_with_arg
          end
        end

        context 'with control ASCII characters' do
          let(:pbn_game_string) { "[TagName #{double_quote}Ta#{form_feed}gValue#{double_quote}" }
          it 'refuses the invalid character' do
            expect { described_object.each_subgame {} }.to raise_error(/.*disallowed.*: 12/)
          end
        end

        context 'with control non-ASCII characters' do
          let (:pbn_game_string) { "[TagName #{double_quote}Ta#{iso_8859_1_dec_val_149}gValue#{double_quote}" }
          it 'refuses the invalid character' do
            expect { described_object.each_subgame {} }.to raise_error(/.*disallowed.*: 149/)
          end
        end

        context 'with a supplemental section containing a string with an open bracket' do
          let(:pbn_game_string) { "[T #{double_quote}v#{double_quote}]#{double_quote}[#{double_quote}" }
          let(:expected_subgame_fields) { [[], %w(T v), [], '"["'] }
          it 'does not consider the bracket to be opening a new tag' do
            expect_first_yield_with_arg
          end
        end
      end
    end

  end
end
