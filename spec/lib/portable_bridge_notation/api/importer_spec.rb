require_relative '../../../../lib/portable_bridge_notation/api/importer'
require 'spec_helper'
module PortableBridgeNotation
  module Api
    RSpec.describe Importer do
      describe('#import') do
        context 'when importing a bad tag name' do
          let(:io) { StringIO.new('[UnrecognizedTagName "UnrecognizedTagValue"]') }
          context 'with an error policy of :throw_exception' do
            let(:error_policy) { :raise_error }
            let(:importer) { described_class.create(error_policy: error_policy) }
            it 'raises an error' do
              called = false
              expect { importer.import(io) { |_game| called = true } }.to raise_error(/UnrecognizedTagName/)
              expect(called).to eq false
            end
          end
          context 'with no error policy specified' do
            let(:logger) { double }
            let(:importer) { described_class.create(logger: logger) }
            it 'logs an error' do
              expect(logger).to receive(:warn).with(/UnrecognizedTagName/)
              called = false
              importer.import(io) { |_game| called = true }
              expect(called).to eq true
            end
          end
        end
        context 'when importing just a deal tag' do
          let(:importer) { described_class.create }
          let(:io) { StringIO.new('[Deal"N:AKQJT9876543.2.. 2.AKQJT9876542.. ..AKQJT98765432. ...AKQJT98765432"]') }
          it 'transforms with_dealt_card calls into ruby hashes within the single yielded game' do
            invocation_count = 0
            importer.import(io) do |game|
              invocation_count += 1
              expect(game.deal[:n][:s]).to eq('AKQJT9876543')
              expect(game.deal[:n][:h]).to eq('2')
              expect(game.deal[:n][:d]).to eq('')
              expect(game.deal[:n][:c]).to eq('')
              expect(game.deal[:e][:s]).to eq('2')
              expect(game.deal[:e][:h]).to eq('AKQJT9876542')
              expect(game.deal[:e][:d]).to eq('')
              expect(game.deal[:e][:c]).to eq('')
              expect(game.deal[:s][:s]).to eq('')
              expect(game.deal[:s][:h]).to eq('')
              expect(game.deal[:s][:d]).to eq('AKQJT98765432')
              expect(game.deal[:s][:c]).to eq('')
              expect(game.deal[:w][:s]).to eq('')
              expect(game.deal[:w][:h]).to eq('')
              expect(game.deal[:w][:d]).to eq('')
              expect(game.deal[:w][:c]).to eq('AKQJT98765432')
            end
            expect(invocation_count).to eq(1)
          end
        end
      end
    end
  end
end
