# frozen_string_literal: true

require 'zinke/dispatcher'

RSpec.describe Zinke::Dispatcher do
  shared_context 'with a listener with no action type' do
    let(:unscoped_listener) { dispatcher.subscribe {} }

    before(:example) { allow(unscoped_listener).to receive(:update) }
  end

  shared_context 'with a listener with a non-matching action type' do
    let(:non_matching_listener) do
      dispatcher.subscribe('spec.actions.other_action') {}
    end

    before(:example) { allow(non_matching_listener).to receive(:update) }
  end

  shared_context 'with a listener with a matching action type' do
    let(:matching_listener) do
      dispatcher.subscribe(action_type: action_type) {}
    end

    before(:example) { allow(matching_listener).to receive(:update) }
  end

  shared_context 'with many listeners' do
    include_context 'with a listener with no action type'
    include_context 'with a listener with a non-matching action type'
    include_context 'with a listener with a matching action type'

    let(:all_listeners) do
      [
        unscoped_listener,
        non_matching_listener,
        matching_listener
      ]
    end
  end

  subject(:dispatcher) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#dispatch' do
    let(:action_type) { 'spec.actions.example_action' }
    let(:action)      { { type: action_type } }

    it { expect(dispatcher).to respond_to(:dispatch).with(1).argument }

    wrap_context 'with a listener with no action type' do
      it 'should call #update on the listener' do
        dispatcher.dispatch(action)

        expect(unscoped_listener).to have_received(:update).with(action)
      end
    end

    wrap_context 'with a listener with a non-matching action type' do
      it 'should call #update on the listener' do
        dispatcher.dispatch(action)

        expect(non_matching_listener).to have_received(:update).with(action)
      end
    end

    wrap_context 'with a listener with a matching action type' do
      it 'should call #update on the listener' do
        dispatcher.dispatch(action)

        expect(matching_listener).to have_received(:update).with(action)
      end
    end

    wrap_context 'with many listeners' do
      it 'should call #update on each listener' do
        dispatcher.dispatch(action)

        expect(all_listeners).to all have_received(:update).with(action).ordered
      end
    end

    context 'when the listener dispatches an action' do
      include_context 'with a listener with no action type'

      let(:inner_type)   { 'spec.actions.inner_action' }
      let(:inner_action) { { type: inner_type } }

      before(:example) do
        inner = inner_action
        dispatcher.subscribe(action_type: action_type) do
          dispatcher.dispatch(inner)
        end
      end

      # rubocop:disable RSpec/ExampleLength
      # rubocop:disable RSpec/MultipleExpectations
      it 'should call #update with the inner action' do
        dispatcher.dispatch(action)

        expect(unscoped_listener)
          .to have_received(:update)
          .with(action)
          .ordered
        expect(unscoped_listener)
          .to have_received(:update)
          .with(inner_action)
          .ordered
      end
      # rubocop:enable RSpec/ExampleLength
      # rubocop:enable RSpec/MultipleExpectations
    end

    context 'when the listener adds a listener' do
      let(:error_message) do
        "can't add a listener while dispatching an action"
      end

      it 'should raise an error' do
        dispatcher.subscribe { dispatcher.subscribe {} }

        expect { dispatcher.dispatch(action) }
          .to raise_error RuntimeError, error_message
      end
    end

    context 'when the listener raises an error' do
      let(:error_message) { 'something has gone terribly wrong' }

      it 'should raise the error' do
        message = error_message
        dispatcher.subscribe { raise message }

        expect { dispatcher.dispatch(action) }
          .to raise_error RuntimeError, error_message
      end
    end
  end

  describe '#subscribe' do
    it 'should define the method' do
      expect(dispatcher)
        .to respond_to(:subscribe)
        .with_unlimited_arguments
        .and_any_keywords
        .and_a_block
    end

    describe 'with no arguments' do
      it 'should return an untyped listener' do
        listener = dispatcher.subscribe {}

        expect(listener).to be_a Zinke::Listeners::BaseListener
      end
    end

    describe 'with action_type: value' do
      let(:action_type) { 'spec.actions.example_action' }

      it 'should return a type listener' do
        listener = dispatcher.subscribe(action_type: action_type) {}

        expect(listener).to be_a Zinke::Listeners::TypeListener
      end

      it 'should set the expected action type' do
        listener = dispatcher.subscribe(action_type: action_type) {}

        expect(listener.action_type).to be action_type
      end
    end
  end

  describe '#unsubscribe' do
    let(:action_type) { 'spec.actions.example_action' }
    let(:action)      { { type: action_type } }

    it { expect(dispatcher).to respond_to(:unsubscribe).with(1).argument }

    wrap_context 'with a listener with no action type' do
      it 'should remove the listener' do
        dispatcher.unsubscribe(unscoped_listener)

        dispatcher.dispatch(action)

        expect(unscoped_listener).not_to have_received(:update)
      end
    end

    wrap_context 'with many listeners' do
      let(:active_listeners) do
        all_listeners.reject { |listener| listener == unscoped_listener }
      end

      it 'should remove the listener' do
        dispatcher.unsubscribe(unscoped_listener)

        dispatcher.dispatch(action)

        expect(unscoped_listener).not_to have_received(:update)
      end

      it 'should not remove the other listeners' do
        dispatcher.unsubscribe(unscoped_listener)

        dispatcher.dispatch(action)

        expect(active_listeners)
          .to all have_received(:update).with(action).ordered
      end
    end
  end
end
