require 'spec_helper'


RSpec.describe Bridge::Pbn::IoParser do
  describe '.each_game' do
    let(:games) do
      result = []
      file_under_test.rewind
      # intent: block passing is used to validate behavior; iterator return is then expected to match block passing
      described_class.each_game_string(file_under_test) { |game| result << game }
      result
    end
    context 'with three valid test records and no multiline comments' do
      let(:file_under_test) { File.open('spec/resource/three_test_records.pbn') }
      context 'when passed a block' do
        it 'passes a total of three games to the given block' do
          expect do |block|
            described_class.each_game_string(file_under_test, &block)
          end.to yield_control.exactly(3).times
        end
        it 'yields all the block arguments in UTF-8 encoding for internal processing' do
          games.each do |game|
            expect(game.encoding).to be Encoding::UTF_8
          end
        end
        it 'discards all escaped lines' do
          games.each { |game| game.each_line { |line| expect(line).not_to match(/^%/) } }
        end
        it 'has the first line of the first game' do
          expect(games[0].lines.first).to eq("[Event \"\"]\n")
        end
        it 'has the last line of the first game' do
          expect(games[0].lines.last).to eq("W  C  0\n")
        end
        it 'has the first line of the last game' do
          expect(games[2].lines.first).to eq("[Event \"\"]\n")
        end
        it 'has the last line of the last game' do
          expect(games[2].lines.last).to eq("W  C 11\n")
        end
      end
      context 'when not passed a block' do
        let(:game_enumerator) { described_class.each_game_string(file_under_test) }
        it 'returns an enumerator instead' do
          expect(game_enumerator).to be_a(Enumerator)
        end
        it 'provides access to all 3 games identically via .to_a' do
          expect(game_enumerator.to_a).to eq(games)
        end
      end
    end
    context 'with three valid test records with CRLF line endings' do
      let(:file_under_test) { File.open('spec/resource/three_test_records_crlf.pbn') }
      it 'passes a total of three games to the given block' do
        expect do |block|
          described_class.each_game_string(file_under_test, &block)
        end.to yield_control.exactly(3).times
      end
      it 'includes the CRLF ending to be dealt with during game parsing' do
        expect(games[0].lines.first).to eq("[Event \"\"]\r\n")
      end
    end
    context 'with one valid test record with a multiline comment containing empty lines' do
      let(:file_under_test) { File.open('spec/resource/test_record_with_empty_line_in_comment.pbn') }
      it 'passes exactly one game to the given block' do
        expect do |block|
          described_class.each_game_string(file_under_test, &block)
        end.to yield_control.once
      end
      context 'with two valid test records, yet one with a single-line curly-comment' do
        let(:file_under_test) { File.open('spec/resource/test_record_with_single_line_curly_comment.pbn') }
        it 'passes two games to the given block' do
          expect do |block|
            described_class.each_game_string(file_under_test, &block)
          end.to yield_control.exactly(2).times
        end
      end
      context 'with two valid test records, yet with lots of curlies for good measure' do
        let(:file_under_test) { File.open('spec/resource/test_record_with_lots_of_curlies.pbn') }
        it 'passes two games to the given block' do
          expect do |block|
            described_class.each_game_string(file_under_test, &block)
          end.to yield_control.exactly(2).times
        end
      end
      context 'within a comment, an escape character' do
        let(:file_under_test) { File.open('spec/resource/test_record_with_escape_in_comment.pbn') }
        it 'does not consider the escape character to actually-escape' do
          expect do |block|
            described_class.each_game_string(file_under_test, &block)
          end.to yield_with_args("[Event \"\"]\n{\n%\n}")
        end
      end
    end
  end
end
