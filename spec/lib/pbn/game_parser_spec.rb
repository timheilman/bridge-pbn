require 'spec_helper'

def setup_single_subgame(pbn_game_string, *subgame_fields)
  subject(:pbn_game_string) {
    pbn_game_string
  }
  Bridge::Pbn::Subgame.new(*subgame_fields)
end

def expect_first_yield_with_arg(expected_arg)
  expect do |block|
    described_class.new.each_subgame(pbn_game_string, &block)
  end.to yield_with_args(expected_arg)
end

RSpec.describe Bridge::Pbn::GameParser do
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
    context('when asked to raise an error') do
      let(:parser) { double }
      let(:described_object) do
        temp = described_class.new
        temp.instance_variable_set(:@state, Bridge::Pbn::BeforeFirstTag.new(parser))
        temp.instance_variable_set(:@cur_char_index, 17)
        temp
      end
      it('Provides the state, char index, and given message') do
        expect { described_object.raise_error 'foobar' }.to raise_error(/.*BeforeFirstTag.*17.*foobar.*/)
      end
    end
  end

  describe('#each_subgame') do
    #### HAPPY PATHS #####

    context('with an opening single-line comment with LF') do
      expected_arg = setup_single_subgame("; just a comment#{LF}",
                                          [' just a comment'], [], [], '')
      it('provides a structure with opening comment, no tag, no following comment, and no section') do
        expect_first_yield_with_arg(expected_arg)
      end
    end

    context('with an opening multi-line comment followed by event tag on the same line') do
      expected_arg = setup_single_subgame(
          "  { multiline #{LF} comment } [TagName #{DOUBLE_QUOTE}TagValue#{DOUBLE_QUOTE}]#{LF}",
          [" multiline #{LF} comment "], %w(TagName TagValue), [], '')
      it('provides a structure with the newline-containing comment, the tag pair, no following comment, no section') do
        expect_first_yield_with_arg(expected_arg)
      end
    end

    context('with a mixture of opening comments') do
      expected_arg = setup_single_subgame(
          ";one-liner#{LF}" +
              "{{{;;;multiline #{LF}" +
              "comment} ;with more commentary#{LF} " +
              " [TagName #{DOUBLE_QUOTE}TagValue#{DOUBLE_QUOTE}]#{LF}",
          ['one-liner', "{{;;;multiline #{LF}comment", 'with more commentary'],
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

    context('with tag value smooshed up against the tag name') do
      expected_arg = setup_single_subgame(
          "[TagName#{DOUBLE_QUOTE}TagValue#{DOUBLE_QUOTE}]",
          [], %w(TagName TagValue), [], '')
      it("doesn't mind the absence of whitespace") do
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
      expected_arg = setup_single_subgame("[TagName #{DOUBLE_QUOTE}TagValue#{DOUBLE_QUOTE}]#{LF}" +
                                              "three section tokens#{DOUBLE_QUOTE}and a string#{DOUBLE_QUOTE}#{LF}",
                                          [], %w(TagName TagValue), [],
                                          "three section tokens#{DOUBLE_QUOTE}and a string#{DOUBLE_QUOTE}#{LF}")
      it('yields the tag pair and the section unprocessed, including quotes and newlines') do
        expect_first_yield_with_arg(expected_arg)
      end
    end

    context('with comment before, one tag pair, comment after, and a section') do
      expected_arg = setup_single_subgame(
          ";comment1#{LF}" +
              "[TagName \"TagValue\" ]#{TAB}#{LF}" +
              "{comment2#{LF}" +
              "comment2 second line}#{LF}" +
              "verbatim section#{LF}",
          ['comment1'],
          %w(TagName TagValue),
          ["comment2#{LF}comment2 second line"],
          "verbatim section#{LF}")
      it('yields the single complete record accurately') do
        expect_first_yield_with_arg(expected_arg)
      end
    end

    context('with two very simple tag pairs') do
      subject(:pbn_game_string) { "[Event #{DOUBLE_QUOTE}#{DOUBLE_QUOTE}]#{LF}[Site #{DOUBLE_QUOTE}#{DOUBLE_QUOTE}]" }
      it('yields twice with the minimal structures') do
        expect do |block|
          described_class.new.each_subgame(pbn_game_string, &block)
        end.to yield_successive_args(Bridge::Pbn::Subgame.new([], ['Event', ''], [], ''),
                                     Bridge::Pbn::Subgame.new([], ['Site', ''], [], ''))
      end
    end

    context('with two very simple tag pairs with comments') do
      subject(:pbn_game_string) { ";preceding comment#{LF}" +
          "[Event #{DOUBLE_QUOTE}#{DOUBLE_QUOTE}] {comment following event} [Site #{DOUBLE_QUOTE}#{DOUBLE_QUOTE}] " +
          ";comment following site#{LF}" }
      it('yields twice with the structures including their commentary') do
        expect do |block|
          described_class.new.each_subgame(pbn_game_string, &block)
        end.to yield_successive_args(Bridge::Pbn::Subgame.new(['preceding comment'], ['Event', ''],
                                                              ['comment following event'], ''),
                                     Bridge::Pbn::Subgame.new([], ['Site', ''],
                                                              ['comment following site'], ''))
      end
    end

    context('with two very simple tag pairs with comments, sections, and CRLF line endings') do
      subject(:pbn_game_string) { "{a1};a2#{CRLF}" +
          "[a3 \"\"] {a4} \"a5\" [b1 \"\"] ;b2 #{CRLF}" +
          "b3 b4#{CRLF}" +
          "b5 b6#{CRLF}" }
      it('yields twice with the structures including their commentary and section data') do
        expect do |block|
          described_class.new.each_subgame(pbn_game_string, &block)
        end.to yield_successive_args(Bridge::Pbn::Subgame.new(%w(a1 a2), ['a3', ''], ['a4'], '"a5" '),
                                     Bridge::Pbn::Subgame.new([], ['b1', ''], ['b2 '],
                                                              "b3 b4#{CRLF}b5 b6#{CRLF}"))
      end
    end

    ###### EDGE CASES #########


    context('with an unclosed curly comment') do
      setup_single_subgame('{unclosed comment')
      it('complains about the unclosed comment') do
        expect { described_class.new.each_subgame(pbn_game_string) {} }.to raise_error(/.*unclosed brace comment.*/)
      end
    end

    context('with a semicolon comment closed by end-of-game') do
      expected_arg = setup_single_subgame('; comment without trailing newline',
                                          [' comment without trailing newline'], [], [], '')
      it('treats end-of-game the same as end-of-line') do
        expect_first_yield_with_arg(expected_arg)
      end
    end

    context('with a barely-opened tag') do
      setup_single_subgame("[#{TAB}#{TAB}  ")
      it('complains about the missing tag name') do
        expect { described_class.new.each_subgame(pbn_game_string) {} }.to raise_error(/.*prior to tag name.*/)
      end
    end

    context('with a tag name followed by end-of-game') do
      setup_single_subgame("[#{TAB}#{TAB}  TagName")
      it('complains about an unfinished tag name') do
        expect { described_class.new.each_subgame(pbn_game_string) {} }.to raise_error(/.*unfinished tag name.*/)
      end
    end

    context('with a tag name but no value') do
      setup_single_subgame("[#{TAB}#{TAB}  TagName ")
      it('complains about the missing tag value') do
        expect { described_class.new.each_subgame(pbn_game_string) {} }.to raise_error(/.*tag value.*/)
      end
    end

    context('with an unclosed tag value') do
      setup_single_subgame("[#{TAB}#{TAB}  TagName #{DOUBLE_QUOTE}TagVal ")
      it('complains about the unclosed string') do
        expect { described_class.new.each_subgame(pbn_game_string) {} }.to raise_error(/.*unclosed string.*/)
      end
    end

    context('with an unclosed tag') do
      setup_single_subgame("[TagName #{DOUBLE_QUOTE}TagValue#{DOUBLE_QUOTE}")
      it('complains about the unclosed tag') do
        expect { described_class.new.each_subgame(pbn_game_string) {} }.to raise_error(/.*unclosed tag.*/)
      end
    end

    context('with an opening single-line comment strangely containing two CRs then an LF') do
      expected_arg = setup_single_subgame("; just a comment#{CR}#{CRLF}",
                                          [" just a comment#{CR}"], [], [], '')
      it('includes only the first CR in the string') do
        expect_first_yield_with_arg(expected_arg)
      end
    end

    context('with an opening single-line comment strangely containing CR in the middle of the string') do
      expected_arg = setup_single_subgame("; just a #{CR}comment#{LF}",
                                          [" just a #{CR}comment"], [], [], '')
      it('includes the CR in the string') do
        expect_first_yield_with_arg(expected_arg)
      end
    end

    context('with printable latin-1 characters') do
      expected_arg = setup_single_subgame("; c'est très bon",
                                          [" c'est très bon"], [], [], '')
      it('handles the latin-1 character just fine') do
        expect_first_yield_with_arg(expected_arg)
      end
    end

    context('with control ASCII characters') do
      setup_single_subgame("[TagName #{DOUBLE_QUOTE}Ta#{FF}gValue#{DOUBLE_QUOTE}")
      it('refuses the invalid character') do
        expect {described_class.new.each_subgame(pbn_game_string) {}}.to raise_error(/.*disallowed.*: 12/)
      end
    end

    context('with control non-ASCII characters') do
      setup_single_subgame("[TagName #{DOUBLE_QUOTE}Ta#{VAL_149}gValue#{DOUBLE_QUOTE}")
      it('refuses the invalid character') do
        expect {described_class.new.each_subgame(pbn_game_string) {}}.to raise_error(/.*disallowed.*: 149/)
      end
    end

  end
end
