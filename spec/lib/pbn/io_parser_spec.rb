require 'spec_helper'


RSpec.describe Bridge::Pbn::IoParser do
  THREE_TEST_RECORDS_FILE = 'spec/resource/three_test_records.pbn'
  THREE_TEST_RECORDS_CRLF_FILE = 'spec/resource/three_test_records_crlf.pbn'
  EMPTY_LINE_IN_COMMENT_FILE = 'spec/resource/test_record_with_empty_line_in_comment.pbn'
  SINGLE_CURLY_COMMENT_FILE = 'spec/resource/test_record_with_single_line_curly_comment.pbn'
  LOTS_OF_CURLIES_FILE = 'spec/resource/test_record_with_single_line_curly_comment.pbn'
  ESCAPE_IN_COMMENT_FILE = 'spec/resource/test_record_with_escape_in_comment.pbn'
  describe '.each_game' do
    context 'with three valid test records and no multiline comments' do
      subject(:games) do
        result = []
        described_class.each_game_string(File.open(THREE_TEST_RECORDS_FILE)) { |game| result << game }
        result
      end
      it 'passes a total of three games to the given block' do
        expect do |block|
          described_class.each_game_string(File.open(THREE_TEST_RECORDS_FILE), &block)
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
        first_line = nil
        games[0].each_line { |line| first_line = line; break }
        expect(first_line).to eq("[Event \"\"]\n")
      end
      it 'has the last line of the first game' do
        last_line = nil
        games[0].each_line { |line| last_line = line }
        expect(last_line).to eq("W  C  0\n")
      end
      it 'has the first line of the last game' do
        first_line = nil
        games[2].each_line { |line| first_line = line; break }
        expect(first_line).to eq("[Event \"\"]\n")
      end
      it 'has the last line of the last game' do
        last_line = nil
        games[2].each_line { |line| last_line = line }
        expect(last_line).to eq("W  C 11\n")
      end
    end
    context 'with three valid test records with CRLF line endings' do
      subject(:games) do
        result = []
        described_class.each_game_string(File.open(THREE_TEST_RECORDS_CRLF_FILE)) { |game| result << game }
        result
      end
      it 'passes a total of three games to the given block' do
        expect do |block|
          described_class.each_game_string(File.open(THREE_TEST_RECORDS_CRLF_FILE), &block)
        end.to yield_control.exactly(3).times
      end
      it 'includes the CRLF ending to be dealt with during game parsing' do
        first_line = nil
        games[0].each_line { |line| first_line = line; break }
        expect(first_line).to eq("[Event \"\"]\r\n")
      end
    end
    context 'with one valid test record with a multiline comment containing empty lines' do
      it 'passes exactly one game to the given block' do
        expect do |block|
          described_class.each_game_string(File.open(EMPTY_LINE_IN_COMMENT_FILE), &block)
        end.to yield_control.once
      end
      context 'with two valid test records, yet one with a single-line curly-comment' do
        it 'passes two games to the given block' do
          expect do |block|
            described_class.each_game_string(File.open(SINGLE_CURLY_COMMENT_FILE), &block)
          end.to yield_control.exactly(2).times
        end
      end
      context 'with two valid test records, yet with lots of curlies for good measure' do
        it 'passes two games to the given block' do
          expect do |block|
            described_class.each_game_string(File.open(LOTS_OF_CURLIES_FILE), &block)
          end.to yield_control.exactly(2).times
        end
      end
      context 'within a comment, an escape character' do
        it 'does not consider the escape character to actually-escape' do
          expect do |block|
            described_class.each_game_string(File.open(ESCAPE_IN_COMMENT_FILE), &block)
          end.to yield_with_args("[Event \"\"]\n{\n%\n}")
        end
      end
    end
  end
end
