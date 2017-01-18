require 'spec_helper'

RSpec.describe Bridge::PbnGameParser do
  describe(".each_tag_and_section") do
    context("with an opening comment") do
      it("yields control once") do
        expect { |block| described_class.each_tag_and_section("; just a comment\n", &block) }.to yield_control.once
      end
    end
  end
end
