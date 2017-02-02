require 'spec_helper'

def expect_first_yield_with_arg
  expect do |block|
    described_class.new.each_subgame(pbn_game_string, &block)
  end.to yield_with_args(expected_arg)
end

RSpec.describe Bridge::Pbn::GameParser do
  let(:expected_arg) { Bridge::Pbn::Subgame.new(*expected_subgame_fields) }

  # intent: to maximize human readability for complicated quoting situations, use constants for all difficult characters
  CR = "\r"
  CRLF = "\r\n"
  LF = "\n"
  FF = "\f"
  VAL_149 = [149].pack('C').force_encoding(Encoding::ISO_8859_1)
  TAB = "\t"
  BACKSLASH = '\\'
  DOUBLE_QUOTE = '"'

  describe('#raise_error') do
    context 'when asked to raise an error' do
      let(:parser) { double }
      let(:builder) { double }
      let(:described_object) do
        temp = described_class.new
        temp.instance_variable_set(:@state, Bridge::Pbn::GameParserStates::BeforeFirstTag.new(parser, builder))
        temp.instance_variable_set(:@cur_char_index, 17)
        temp
      end
      it 'Provides the state, char index, and given message' do
        expect { described_object.raise_error 'foobar' }.to raise_error(/.*BeforeFirstTag.*17.*foobar.*/)
      end
    end
  end

  describe('#each_subgame') do
    #### HAPPY PATHS #####

    context 'with an opening single-line comment with LF' do
      let(:pbn_game_string) { "; just a comment#{LF}" }
      let(:expected_subgame_fields) { [[' just a comment'], [], [], ''] }
      it 'provides a structure with opening comment, no tag, no following comment, and no section' do
        expect_first_yield_with_arg
      end
    end

    context 'with an opening multi-line comment followed by event tag on the same line' do
      let(:pbn_game_string) { "  { multiline #{LF} comment } [TagName #{DOUBLE_QUOTE}TagValue#{DOUBLE_QUOTE}]#{LF}" }
      let(:expected_subgame_fields) { [[" multiline #{LF} comment "], %w(TagName TagValue), [], ''] }
      it 'provides a structure with the newline-containing comment, the tag pair, no following comment, no section' do
        expect_first_yield_with_arg
      end
    end

    context 'with a mixture of opening comments' do
      let(:pbn_game_string) do
        ";one-liner#{LF}" +
            "{{{;;;multiline #{LF}" +
            "comment} ;with more commentary#{LF} " +
            " [TagName #{DOUBLE_QUOTE}TagValue#{DOUBLE_QUOTE}]#{LF}"
      end
      let(:expected_subgame_fields) { [['one-liner', "{{;;;multiline #{LF}comment", 'with more commentary'],
                                       %w(TagName TagValue), [], ''] }
      it 'provides multiple comments in the structure' do
        expect_first_yield_with_arg
      end
    end

    context 'with double-quotes in the tag value' do
      let(:pbn_game_string) { "[TagName #{DOUBLE_QUOTE}Tag#{BACKSLASH}#{DOUBLE_QUOTE}Value#{DOUBLE_QUOTE}]" }
      let(:expected_subgame_fields) { [[], %w(TagName Tag"Value), [], ''] }
      it 'handles escaped double-quotes properly' do
        expect_first_yield_with_arg
      end
    end

    context 'with tag value smooshed up against the tag name' do
      let(:pbn_game_string) { "[TagName#{DOUBLE_QUOTE}TagValue#{DOUBLE_QUOTE}]" }
      let(:expected_subgame_fields) { [[], %w(TagName TagValue), [], ''] }
      it "doesn't mind the absence of whitespace" do
        expect_first_yield_with_arg
      end
    end

    context 'with backslash in the tag value' do
      let(:pbn_game_string) { "[TagName #{DOUBLE_QUOTE}Tag#{BACKSLASH}#{BACKSLASH}Value#{DOUBLE_QUOTE}]" }
      let(:expected_subgame_fields) { [[], ['TagName', "Tag#{BACKSLASH}Value"], [], ''] }
      it 'handles escaped backslashes properly' do
        expect_first_yield_with_arg
      end
    end

    context 'with no comments, one tag pair, and a section' do
      let(:pbn_game_string) do
        "[TagName #{DOUBLE_QUOTE}TagValue#{DOUBLE_QUOTE}]#{LF}" +
            "three section tokens#{DOUBLE_QUOTE}and a string#{DOUBLE_QUOTE}#{LF}"
      end
      let(:expected_subgame_fields) do
        [[], %w(TagName TagValue), [],
         "three section tokens#{DOUBLE_QUOTE}and a string#{DOUBLE_QUOTE}#{LF}"]
      end
      it 'yields the tag pair and the section unprocessed, including quotes and newlines' do
        expect_first_yield_with_arg
      end
    end

    context 'with comment before, one tag pair, comment after, and a section' do
      let(:pbn_game_string) do
        ";comment1#{LF}" +
            "[TagName \"TagValue\" ]#{TAB}#{LF}" +
            "{comment2#{LF}" +
            "comment2 second line}#{LF}" +
            "verbatim section#{LF}"
      end
      let(:expected_subgame_fields) do
        [['comment1'],
         %w(TagName TagValue),
         ["comment2#{LF}comment2 second line"],
         "verbatim section#{LF}"]
      end
      it 'yields the single complete record accurately' do
        expect_first_yield_with_arg
      end
    end

    context 'with two very simple tag pairs' do
      let(:pbn_game_string) { "[Event #{DOUBLE_QUOTE}#{DOUBLE_QUOTE}]#{LF}[Site #{DOUBLE_QUOTE}#{DOUBLE_QUOTE}]" }
      it 'yields twice with the minimal structures' do
        expect do |block|
          described_class.new.each_subgame(pbn_game_string, &block)
        end.to yield_successive_args(Bridge::Pbn::Subgame.new([], ['Event', ''], [], ''),
                                     Bridge::Pbn::Subgame.new([], ['Site', ''], [], ''))
      end
    end

    context 'with two very simple tag pairs with comments' do
      let(:pbn_game_string) { ";preceding comment#{LF}" +
          "[Event #{DOUBLE_QUOTE}#{DOUBLE_QUOTE}] {comment following event} [Site #{DOUBLE_QUOTE}#{DOUBLE_QUOTE}] " +
          ";comment following site#{LF}" }
      it 'yields twice with the structures including their commentary' do
        expect do |block|
          described_class.new.each_subgame(pbn_game_string, &block)
        end.to yield_successive_args(Bridge::Pbn::Subgame.new(['preceding comment'], ['Event', ''],
                                                              ['comment following event'], ''),
                                     Bridge::Pbn::Subgame.new([], ['Site', ''],
                                                              ['comment following site'], ''))
      end
    end

    context 'with two very simple tag pairs with comments, sections, and CRLF line endings' do
      subject(:pbn_game_string) { "{a1};a2#{CRLF}" +
          "[a3 \"\"] {a4} \"a5\" [b1 \"\"] ;b2 #{CRLF}" +
          "b3 b4#{CRLF}" +
          "b5 b6#{CRLF}" }
      it 'yields twice with the structures including their commentary and section data' do
        expect do |block|
          described_class.new.each_subgame(pbn_game_string, &block)
        end.to yield_successive_args(Bridge::Pbn::Subgame.new(%w(a1 a2), ['a3', ''], ['a4'], '"a5" '),
                                     Bridge::Pbn::Subgame.new([], ['b1', ''], ['b2 '],
                                                              "b3 b4#{CRLF}b5 b6#{CRLF}"))
      end
    end

    ###### EDGE CASES #########

    context 'with an unclosed curly comment' do
      let(:pbn_game_string) { '{unclosed comment' }
      it 'complains about the unclosed comment' do
        expect { described_class.new.each_subgame(pbn_game_string) {} }.to raise_error(/.*unclosed brace comment.*/)
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
      let(:pbn_game_string) { "[#{TAB}#{TAB}  " }
      it 'complains about the missing tag name' do
        expect { described_class.new.each_subgame(pbn_game_string) {} }.to raise_error(/.*prior to tag name.*/)
      end
    end

    context 'with a tag name followed by end-of-game' do
      let(:pbn_game_string) { "[#{TAB}#{TAB}  TagName" }
      it 'complains about an unfinished tag name' do
        expect { described_class.new.each_subgame(pbn_game_string) {} }.to raise_error(/.*unfinished tag name.*/)
      end
    end

    context 'with a tag name but no value' do
      let(:pbn_game_string) { "[#{TAB}#{TAB}  TagName " }
      it 'complains about the missing tag value' do
        expect { described_class.new.each_subgame(pbn_game_string) {} }.to raise_error(/.*tag value.*/)
      end
    end

    context 'with an unclosed tag value' do
      let(:pbn_game_string) { "[#{TAB}#{TAB}  TagName #{DOUBLE_QUOTE}TagVal " }
      it 'complains about the unclosed string' do
        expect { described_class.new.each_subgame(pbn_game_string) {} }.to raise_error(/.*unclosed string.*/)
      end
    end

    context 'with an unclosed tag' do
      let(:pbn_game_string) { "[TagName #{DOUBLE_QUOTE}TagValue#{DOUBLE_QUOTE}" }
      it 'complains about the unclosed tag' do
        expect { described_class.new.each_subgame(pbn_game_string) {} }.to raise_error(/.*unclosed tag.*/)
      end
    end

    context 'with an opening single-line comment strangely containing two CRs then an LF' do
      let(:pbn_game_string) { "; just a comment#{CR}#{CRLF}" }
      let(:expected_subgame_fields) { [[" just a comment#{CR}"], [], [], ''] }
      it 'includes only the first CR in the string' do
        expect_first_yield_with_arg
      end
    end

    context 'with an opening single-line comment strangely containing CR in the middle of the string' do
      let(:pbn_game_string) { "; just a #{CR}comment#{LF}" }
      let(:expected_subgame_fields) { [[" just a #{CR}comment"], [], [], ''] }
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
      let(:pbn_game_string) { "[TagName #{DOUBLE_QUOTE}Ta#{FF}gValue#{DOUBLE_QUOTE}" }
      it 'refuses the invalid character' do
        expect { described_class.new.each_subgame(pbn_game_string) {} }.to raise_error(/.*disallowed.*: 12/)
      end
    end

    context 'with control non-ASCII characters' do
      let (:pbn_game_string) { "[TagName #{DOUBLE_QUOTE}Ta#{VAL_149}gValue#{DOUBLE_QUOTE}" }
      it 'refuses the invalid character' do
        expect { described_class.new.each_subgame(pbn_game_string) {} }.to raise_error(/.*disallowed.*: 149/)
      end
    end

    context 'with a supplemental section containing a string with an open bracket' do
      let(:pbn_game_string) { "[T #{DOUBLE_QUOTE}v#{DOUBLE_QUOTE}]#{DOUBLE_QUOTE}[#{DOUBLE_QUOTE}" }
      let(:expected_subgame_fields) { [[], %w(T v), [], '"["'] }
      it 'does not consider the bracket to be opening a new tag' do
        expect_first_yield_with_arg
      end
    end
  end
end
