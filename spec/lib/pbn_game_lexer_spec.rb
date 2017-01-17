require 'spec_helper'

RSpec.describe Bridge::PbnGameLexer do
  # intent: since parallelism is planned via a priori explicit separation of data into independent subsets
  # that can be acted on by independent threads (and thus instances of ruby) on separate cores,
  # lex will be a class method, since each ruby instance thus parallelized will have its own PbnGameLexer class
  describe '.lex' do
    it 'Recognizes square brackets' do
      expect(described_class.lex('[][][]')).to eq (%w([ ] [ ] [ ]))
    end
  end
end