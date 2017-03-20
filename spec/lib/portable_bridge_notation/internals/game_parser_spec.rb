require 'spec_helper'
require_relative '../../../../lib/portable_bridge_notation/internals/single_char_comparison_constants'
require_relative '../../../../lib/portable_bridge_notation/internals/subgame'
require_relative '../../../../lib/portable_bridge_notation/internals/injector'

module PortableBridgeNotation
  module Internals
    module GameParserStates
      class InTagNameSection < InUnrecognizedSupplementalSection
      end
    end

    RSpec.describe GameParser do
      # intent: to maximize human readability for quoting situations, use bare words for all difficult characters
      include SingleCharComparisonConstants

      let(:expected_arg) do
        expected_game = Api::Game.new
        expected_game.initial_comments = expected_subgame_fields[0]
        tag_name = expected_subgame_fields[1][0]
        unless tag_name.nil?
          expected_game.supplemental_sections[tag_name.to_sym] =
            Api::SupplementalSection.new expected_subgame_fields[1][1],
                                         expected_subgame_fields[3],
                                         expected_subgame_fields[2]
        end
        expected_game
      end

      def perform_test_with_expected_arg
        game = conduct_test
        expect(game).to eq expected_arg
      end

      def conduct_test
        described_object.parse
        game_parser_listener.build
      end

      let(:factory) { Injector.new }
      let(:game_parser_listener) { factory.game_parser_listener }
      let(:described_object) do
        factory.game_parser(pbn_game_string, Logger.new(STDERR), game_parser_listener)
      end
      describe('#each_subgame') do
        #### HAPPY PATHS #####

        context 'with an opening single-line comment with LF' do
          let(:pbn_game_string) { "; just a comment#{line_feed}" }
          let(:expected_subgame_fields) { [[' just a comment'], [], [], ''] }
          it 'provides a structure with opening comment, no tag, no following comment, and no section' do
            perform_test_with_expected_arg
          end
        end

        context 'with an opening multi-line comment followed by event tag on the same line' do
          let(:pbn_game_string) do
            "  { multiline #{line_feed}" \
            "comment } [TagName #{double_quote}TagValue#{double_quote}]#{line_feed}"
          end
          let(:expected_subgame_fields) { [[" multiline #{line_feed}comment "], %w(TagName TagValue), [], ''] }
          it 'provides a structure with the multi-line comment, the tag pair, no following comment, no section' do
            perform_test_with_expected_arg
          end
        end

        context 'with a mixture of opening comments' do
          let(:pbn_game_string) do
            ";one-liner#{line_feed}" \
              "{{{;;;multiline #{line_feed}" \
              "comment} ;with more commentary#{line_feed} " \
              " [TagName #{double_quote}TagValue#{double_quote}]#{line_feed}"
          end
          let(:expected_subgame_fields) do
            [['one-liner', "{{;;;multiline #{line_feed}comment", 'with more commentary'],
             %w(TagName TagValue), [], '']
          end
          it 'provides multiple comments in the structure' do
            perform_test_with_expected_arg
          end
        end

        context 'with double-quotes in the tag value' do
          let(:pbn_game_string) { "[TagName #{double_quote}Tag#{backslash + double_quote}Value#{double_quote}]" }
          let(:expected_subgame_fields) { [[], %w(TagName Tag"Value), [], ''] }
          it 'handles escaped double-quotes properly' do
            perform_test_with_expected_arg
          end
        end

        context 'with tag value smooshed up against the tag name' do
          let(:pbn_game_string) { "[TagName#{double_quote}TagValue#{double_quote}]" }
          let(:expected_subgame_fields) { [[], %w(TagName TagValue), [], ''] }
          it "doesn't mind the absence of whitespace" do
            perform_test_with_expected_arg
          end
        end

        context 'with backslash in the tag value' do
          let(:pbn_game_string) { "[TagName #{double_quote}Tag#{backslash + backslash}Value#{double_quote}]" }
          let(:expected_subgame_fields) { [[], ['TagName', "Tag#{backslash}Value"], [], ''] }
          it 'handles escaped backslashes properly' do
            perform_test_with_expected_arg
          end
        end

        context 'with no comments, one tag pair, and a section' do
          let(:pbn_game_string) do
            "[TagName #{double_quote}TagValue#{double_quote}]#{line_feed}" \
              "three section tokens#{double_quote}and a string#{double_quote + line_feed}"
          end
          let(:expected_subgame_fields) do
            [[], %w(TagName TagValue), [],
             "\nthree section tokens#{double_quote}and a string#{double_quote + line_feed}"]
          end
          it 'yields the tag pair and the section unprocessed, including quotes and newlines' do
            perform_test_with_expected_arg
          end
        end

        context 'with comment before, one tag pair, comment after, and a section' do
          let(:pbn_game_string) do
            ";comment1#{line_feed}" \
              "[TagName \"TagValue\" ]#{tab}#{line_feed}" \
              "{comment2#{line_feed}" \
              "comment2 second line}#{line_feed}" \
              "verbatim section#{line_feed}"
          end
          let(:expected_subgame_fields) do
            [['comment1'],
             %w(TagName TagValue),
             ["comment2#{line_feed}comment2 second line"],
             "#{line_feed}verbatim section#{line_feed}"]
          end
          it 'yields the single complete record accurately' do
            perform_test_with_expected_arg
          end
        end

        context 'with two very simple non-supplemental informational tag pairs' do
          let(:pbn_game_string) do
            "[Event #{double_quote + double_quote}]#{line_feed}" \
            "[Site #{double_quote + double_quote}]"
          end
          it 'yields a game with the known fields populated' do
            game = conduct_test
            expect(game.event).to eq ''
            expect(game.site).to eq ''
          end
        end

        context 'with two very simple tag pairs with comments' do
          let(:pbn_game_string) do
            ";preceding comment#{line_feed}" \
            "[Event #{double_quote + double_quote}] {comment following event} " + # no line_feed!
              "[Site #{double_quote + double_quote}] " \
          ";comment following site#{line_feed}"
          end
          it 'yields twice with the structures including their commentary' do
            game = conduct_test
            expect(game.initial_comments[0]).to eq 'preceding comment'
            expect(game.event).to eq ''
            expect(game.event_comments).to eq ['comment following event']
            expect(game.site).to eq ''
            expect(game.site_comments).to eq ['comment following site']
          end
        end

        context 'with two very simple tag pairs with comments, sections, and CRLF line endings' do
          subject(:pbn_game_string) do
            "{a1};a2#{carriage_return + line_feed}" \
            "[a3 \"\"] {a4} \"a5\" [b1 \"\"] ;b2 #{carriage_return + line_feed}" \
            "b3 b4#{carriage_return + line_feed}" \
            "b5 b6#{carriage_return + line_feed}"
          end
          it 'yields twice with the structures including their commentary and section data' do
            game = conduct_test
            expect(game.initial_comments[0]).to eq 'a1'
            expect(game.initial_comments[1]).to eq 'a2'
            expect(game.supplemental_sections[:a3].tag_value).to eq ''
            expect(game.supplemental_sections[:a3].comments[0]).to eq 'a4'
            expect(game.supplemental_sections[:a3].section_string).to eq ' "a5" '
            expect(game.supplemental_sections[:b1].tag_value).to eq ''
            expect(game.supplemental_sections[:b1].comments[0]).to eq 'b2 '
            expect(game.supplemental_sections[:b1].section_string).to eq "b3 b4#{carriage_return + line_feed}" \
                                                         "b5 b6#{carriage_return + line_feed}"
          end
        end

        ###### EDGE CASES #########

        context 'with an unclosed curly comment' do
          let(:pbn_game_string) { '{unclosed comment' }
          it 'complains about the unclosed comment' do
            expect { conduct_test }.to raise_error(/.*unclosed brace comment.*/)
          end
        end

        context 'with a semicolon comment closed by end-of-game' do
          let(:pbn_game_string) { '; comment without trailing newline' }
          let(:expected_subgame_fields) { [[' comment without trailing newline'], [], [], ''] }
          it 'treats end-of-game the same as end-of-line' do
            perform_test_with_expected_arg
          end
        end

        context 'with a barely-opened tag' do
          let(:pbn_game_string) { "[#{tab}#{tab}  " }
          it 'complains about the missing tag name' do
            expect { conduct_test }.to raise_error(/.*prior to tag name.*/)
          end
        end

        context 'with a tag name followed by end-of-game' do
          let(:pbn_game_string) { "[#{tab}#{tab}  TagName" }
          it 'complains about an unfinished tag name' do
            expect { conduct_test }.to raise_error(/.*unfinished tag name.*/)
          end
        end

        context 'with a tag name but no value' do
          let(:pbn_game_string) { "[#{tab + tab}  TagName " }
          it 'complains about the missing tag value' do
            expect { conduct_test }.to raise_error(/.*tag value.*/)
          end
        end

        context 'with an unclosed tag value' do
          let(:pbn_game_string) { "[#{tab + tab}  TagName #{double_quote}TagVal " }
          it 'complains about the unclosed string' do
            expect { conduct_test }.to raise_error(/.*unclosed string.*/)
          end
        end

        context 'with an unclosed tag' do
          let(:pbn_game_string) { "[TagName #{double_quote}TagValue#{double_quote}" }
          it 'complains about the unclosed tag' do
            expect { conduct_test }.to raise_error(/.*unclosed tag.*/)
          end
        end

        context 'with an opening single-line comment strangely containing two CRs then an LF' do
          let(:pbn_game_string) { "; just a comment#{carriage_return + carriage_return + line_feed}" }
          let(:expected_subgame_fields) { [[" just a comment#{carriage_return}"], [], [], ''] }
          it 'includes only the first CR in the string' do
            perform_test_with_expected_arg
          end
        end

        context 'with an opening single-line comment containing carriage_return in the middle of the string' do
          let(:pbn_game_string) { "; just a #{carriage_return}comment#{line_feed}" }
          let(:expected_subgame_fields) { [[" just a #{carriage_return}comment"], [], [], ''] }
          it 'includes the CR in the string' do
            perform_test_with_expected_arg
          end
        end

        context 'with printable latin-1 characters' do
          let(:pbn_game_string) { "; c'est très bon" }
          let(:expected_subgame_fields) { [[" c'est très bon"], [], [], ''] }
          it 'handles the latin-1 character just fine' do
            perform_test_with_expected_arg
          end
        end

        context 'with control ASCII characters' do
          let(:pbn_game_string) { "[TagName #{double_quote}Ta#{form_feed}gValue#{double_quote}" }
          it 'refuses the invalid character' do
            expect { conduct_test }.to raise_error(/.*disallowed.*: 12/)
          end
        end

        context 'with control non-ASCII characters' do
          let(:pbn_game_string) { "[TagName #{double_quote}Ta#{iso_8859_1_dec_val_149}gValue#{double_quote}" }
          it 'refuses the invalid character' do
            expect { conduct_test }.to raise_error(/.*disallowed.*: 149/)
          end
        end

        context 'with a supplemental section containing a string with an open bracket' do
          let(:pbn_game_string) { "[T #{double_quote}v#{double_quote}]#{double_quote}[#{double_quote}" }
          let(:expected_subgame_fields) { [[], %w(T v), [], '"["'] }
          it 'does not consider the bracket to be opening a new tag' do
            perform_test_with_expected_arg
          end
        end
      end
      describe('#add_note_ref_resolution') do
        context('when a play section has been reached and a note reference has occurred') do
          let(:pbn_game_string) { '' }
          it 'provides back the note references it was informed of when asked' do
            described_object.reached_section('Play')
            described_object.add_note_ref_resolution(2, 'two colors: clubs and diamonds')
            expect(described_object.get_note_ref(2)).to eq('two colors: clubs and diamonds')
          end
        end
      end
    end
  end
end
