# frozen_string_literal: true

require 'zinke/listeners/base_listener'

RSpec.describe Zinke::Listeners::BaseListener do
  subject(:listener) { described_class.new(&definition) }

  let(:definition) { ->(_action) {} }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_a_block
    end

    describe 'with no arguments' do
      let(:error_message) { 'must provide a block' }

      it 'should raise an error' do
        expect { described_class.new }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a block' do
      it { expect { described_class.new(&definition) }.not_to raise_error }
    end
  end

  describe '#update' do
    let(:action) { { type: 'spec.actions.example_action' } }

    it { expect(listener).to respond_to(:update).with(1).argument }

    it 'should yield the action to the block' do
      expect { |block| described_class.new(&block).update(action) }
        .to yield_with_args(action)
    end
  end
end
