require 'spec_helper'
require_relative '../../../../lib/portable_bridge_notation/internals/portable_bridge_notation_error'
require_relative '../../../../lib/portable_bridge_notation/internals/concrete_factory'

module PortableBridgeNotation
  module Internals
    RSpec.describe ConcreteFactory do
      describe('.parse') do
        context('when it is called') do
          let(:domain_builder) { double }
          let(:logger) { double }
          context('and the result is asked to handle a real tag subgame') do
            let(:parser) { described_class.new.make_subgame_parser(domain_builder, 'Deal') }
            it('returns a subgame parser') do
              expect(parser).to respond_to :parse
            end
          end
          context('and the result is asked to handle a nonsense tag subgame') do
            it('throws a PortableBridgeNotationError') do
              expect { described_class.new.make_subgame_parser(domain_builder, 'NotAValidTagName') }
                .to raise_error(PortableBridgeNotationError)
            end
          end
        end
      end
    end
  end
end
