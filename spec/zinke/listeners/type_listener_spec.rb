# frozen_string_literal: true

require 'zinke/listeners/type_listener'

RSpec.describe Zinke::Listeners::TypeListener do
  subject(:listener) do
    described_class.new(action_type: action_type, &definition)
  end

  let(:definition)  { ->(_action) {} }
  let(:action_type) { 'spec.actions.example_action' }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:action_type)
        .and_a_block
    end

    describe 'with no arguments' do
      let(:error_message) { 'must provide a block' }

      it 'should raise an error' do
        expect { described_class.new(action_type: action_type) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a block' do
      it 'should not raise an error' do
        expect { described_class.new(action_type: action_type, &definition) }
          .not_to raise_error
      end
    end
  end

  describe '#action_type' do
    include_examples 'should have reader', :action_type, -> { action_type }
  end

  describe '#update' do
    describe 'with an action with non-matching type' do
      let(:action) { { type: 'spec.actions.other_action' } }

      it 'should not call the definition' do
        allow(definition).to receive(:call)

        listener.update(action)

        expect(definition).not_to have_received(:call)
      end
    end

    describe 'with an action with matching type' do
      let(:action) { { type: action_type } }

      it 'should call the definition with the action' do
        allow(definition).to receive(:call)

        listener.update(action)

        expect(definition).to have_received(:call).with(action)
      end
    end
  end
end
