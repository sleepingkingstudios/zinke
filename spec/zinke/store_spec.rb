# frozen_string_literal: true

require 'zinke/store'

RSpec.describe Zinke::Store do
  shared_context 'with a listener with no action type' do
    let(:unscoped_listener) { store.subscribe {} }

    before(:example) { allow(unscoped_listener).to receive(:update) }
  end

  shared_context 'with a listener with a non-matching action type' do
    let(:non_matching_listener) do
      store.subscribe('spec.actions.other_action') {}
    end

    before(:example) { allow(non_matching_listener).to receive(:update) }
  end

  shared_context 'with a listener with a matching action type' do
    let(:matching_listener) { store.subscribe(type) {} }

    before(:example) { allow(matching_listener).to receive(:update) }
  end

  subject(:store) { described_class.new(initial_state) }

  let(:initial_state) { nil }

  describe '::new' do
    let(:error_message) do
      'initial state must be a Hash or nil'
    end

    it { expect(described_class).to be_constructible.with(0..1).arguments }

    describe 'with an Object' do
      let(:object)        { Object.new }
      let(:error_message) { super() + ", but was #{object.inspect}" }

      it 'should raise an error' do
        expect { described_class.new object }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Array' do
      let(:object)        { [] }
      let(:error_message) { super() + ", but was #{object.inspect}" }

      it 'should raise an error' do
        expect { described_class.new object }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  describe '#dispatch' do
    let(:type)   { 'spec.actions.example_action' }
    let(:action) { { type: type } }

    it { expect(store).to respond_to(:dispatch).with(1).argument }

    wrap_context 'with a listener with no action type' do
      it 'should call #update with the action' do
        store.dispatch(action)

        expect(unscoped_listener).to have_received(:update).with(action)
      end
    end

    wrap_context 'with a listener with a non-matching action type' do
      it 'should call #update with the action' do
        store.dispatch(action)

        expect(non_matching_listener).to have_received(:update).with(action)
      end
    end

    wrap_context 'with a listener with a matching action type' do
      it 'should call #update with the action' do
        store.dispatch(action)

        expect(matching_listener).to have_received(:update).with(action)
      end
    end

    context 'with multiple listeners' do
      include_context 'with a listener with no action type'
      include_context 'with a listener with a non-matching action type'
      include_context 'with a listener with a matching action type'

      let(:listeners) do
        [
          unscoped_listener,
          non_matching_listener,
          matching_listener
        ]
      end

      it 'should call #update on each listener with the action' do
        store.dispatch(action)

        expect(listeners).to all have_received(:update).with(action)
      end
    end

    context 'when the listener dispatches an action' do
      include_context 'with a listener with no action type'

      let(:actions)      { [] }
      let(:inner_type)   { 'spec.actions.inner_action' }
      let(:inner_action) { { type: inner_type } }

      before(:example) do
        inner = inner_action
        store.subscribe(type) { store.dispatch(inner) }
      end

      # rubocop:disable RSpec/ExampleLength
      # rubocop:disable RSpec/MultipleExpectations
      it 'should call #update with the inner action' do
        store.dispatch(action)

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
        store.subscribe { store.subscribe }

        expect { store.dispatch(action) }
          .to raise_error RuntimeError, error_message
      end
    end

    context 'when the listener raises an error' do
      let(:error_message) { 'something has gone terribly wrong' }

      it 'should raise the error' do
        message = error_message
        store.subscribe { raise message }

        expect { store.dispatch(action) }
          .to raise_error RuntimeError, error_message
      end
    end
  end

  describe '#state' do
    include_examples 'should have reader', :state

    describe 'when initialized with no arguments' do
      let(:store) { described_class.new }

      it { expect(store.state).to be_a Hamster::Hash }

      it { expect(store.state).to be == {} }
    end

    describe 'when the initial state is nil' do
      let(:initial_state) { nil }

      it { expect(store.state).to be_a Hamster::Hash }

      it { expect(store.state).to be == {} }
    end

    describe 'when the initial state is an empty hash' do
      let(:initial_state) { {} }

      it { expect(store.state).to be_a Hamster::Hash }

      it { expect(store.state).to be == {} }
    end

    describe 'when the initial state is a hash with string keys' do
      let(:initial_state) do
        {
          'era'   => 'Renaissance',
          'genre' => 'High Fantasy',
          'magic' => :high
        }
      end
      let(:expected) do
        {
          era:   'Renaissance',
          genre: 'High Fantasy',
          magic: :high
        }
      end

      it { expect(store.state).to be_a Hamster::Hash }

      it { expect(store.state).to be == expected }
    end

    describe 'when the initial state is a hash with symbol keys' do
      let(:initial_state) do
        {
          era:   'Renaissance',
          genre: 'High Fantasy',
          magic: :high
        }
      end
      let(:expected) { initial_state }

      it { expect(store.state).to be_a Hamster::Hash }

      it { expect(store.state).to be == expected }
    end

    describe 'when the initial state is an immutable hash' do
      let(:initial_state) do
        Hamster::Hash.new(
          era:   'Renaissance',
          genre: 'High Fantasy',
          magic: :high
        )
      end
      let(:expected) do
        {
          era:   'Renaissance',
          genre: 'High Fantasy',
          magic: :high
        }
      end

      it { expect(store.state).to be_a Hamster::Hash }

      it { expect(store.state).to be == expected }
    end

    describe 'when the initial state is a hash with nested values' do
      let(:initial_state) do
        {
          weapons: {
            bows: Set.new(%w[crossbow longbow shortbow]),
            polearms: %w[halberd pike spear],
            swords: {
              japanese: Set.new(%w[shoto daito tachi])
            }
          }
        }
      end
      let(:expected) do
        Hamster::Hash.new(
          weapons: Hamster::Hash.new(
            bows: Hamster::Set.new(%w[crossbow longbow shortbow]),
            polearms: Hamster::Vector.new(%w[halberd pike spear]),
            swords: Hamster::Hash.new(
              japanese: Hamster::Set.new(%w[shoto daito tachi])
            )
          )
        )
      end

      it { expect(store.state).to be_a Hamster::Hash }

      it { expect(store.state).to be == expected }
    end
  end

  describe '#state=' do
    let(:new_state) do
      Hamster::Hash.new(
        era:   'Renaissance',
        genre: 'High Fantasy',
        magic: :high
      )
    end

    include_examples 'should have private writer', :state=

    it 'should set the state' do
      expect { store.send :state=, new_state }
        .to change(store, :state)
        .to new_state
    end
  end

  describe '#subscribe' do
    let(:type)   { 'spec.actions.example_action' }
    let(:action) { { type: type } }

    it 'should define the method' do
      expect(store).to respond_to(:subscribe).with(0..1).arguments.and_a_block
    end

    describe 'with no action type' do
      it { expect(store.subscribe {}).to be_a described_class::Listener }

      context 'when an action is dispatched' do
        it 'should yield the block' do
          expect do |block|
            store.subscribe(&block)

            store.dispatch(action)
          end
            .to yield_with_args(action)
        end
      end
    end

    describe 'with an action type' do
      it { expect(store.subscribe(type) {}).to be_a described_class::Listener }

      context 'when a non-matching action is dispatched' do
        let(:action) { { type: 'spec.actions.other_action' } }

        it 'should yield the block' do
          expect do |block|
            store.subscribe(type, &block)

            store.dispatch(action)
          end
            .not_to yield_control
        end
      end

      context 'when a matching action is dispatched' do
        it 'should yield the block' do
          expect do |block|
            store.subscribe(type, &block)

            store.dispatch(action)
          end
            .to yield_with_args(action)
        end
      end
    end
  end

  describe '#unsubscribe' do
    let(:type)   { 'spec.actions.example_action' }
    let(:action) { { type: type } }

    it { expect(store).to respond_to(:unsubscribe).with(1).argument }

    wrap_context 'with a listener with no action type' do
      context 'when an action is dispatched' do
        it 'should not call #update' do
          store.unsubscribe(unscoped_listener)

          store.dispatch(action)

          expect(unscoped_listener).not_to have_received(:update)
        end
      end
    end

    context 'with multiple listeners' do
      include_context 'with a listener with no action type'
      include_context 'with a listener with a non-matching action type'
      include_context 'with a listener with a matching action type'

      let(:active_listeners) do
        [
          non_matching_listener,
          matching_listener
        ]
      end

      context 'when an action is dispatched' do
        it 'should not call #update on the unsubscribed listener' do
          store.unsubscribe(unscoped_listener)

          store.dispatch(action)

          expect(unscoped_listener).not_to have_received(:update)
        end

        it 'should call #update on each remaining listener with the action' do
          store.unsubscribe(unscoped_listener)

          store.dispatch(action)

          expect(active_listeners).to all have_received(:update).with(action)
        end
      end
    end
  end
end
