# frozen_string_literal: true

require 'zinke/store'

RSpec.describe Zinke::Store do
  shared_context 'when the dispatcher has a subscribed listener' do
    let(:handler_method) { defined?(super()) ? super() : :update }
    let(:listener)       { store.subscribe {} }

    before(:example) { allow(listener).to receive(handler_method) }
  end

  shared_context 'when the store defines #build_dispatcher' do
    let(:described_class) { Spec::ExampleStore }
    let(:handler_method)  { :call }

    example_class 'Spec::CustomDispatcher' do |klass|
      # rubocop:disable RSpec/InstanceVariable
      klass.class_eval do
        def initialize
          @handlers = []
        end

        def dispatch(action)
          @handlers.each { |handler| handler.call(action) }
        end

        def subscribe(&block)
          @handlers << block

          block
        end

        def unsubscribe(proc)
          @handlers.delete(proc)
        end
      end
      # rubocop:enable RSpec/InstanceVariable
    end

    # rubocop:disable RSpec/DescribedClass
    example_class 'Spec::ExampleStore', Zinke::Store do |klass|
      klass.send :define_method, :build_dispatcher do
        Spec::CustomDispatcher.new
      end
    end
    # rubocop:enable RSpec/DescribedClass
  end

  shared_context 'when the store has a custom dispatcher' do
    let(:dispatcher) { Spec::ExampleDispatcher.new }
    let(:store)      { described_class.new(state, dispatcher: dispatcher) }

    example_class 'Spec::ExampleDispatcher', Zinke::Dispatcher
  end

  subject(:store) { described_class.new(state) }

  let(:state) { nil }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..2).arguments }
  end

  describe '#dispatch' do
    let(:action) { { type: 'spec.actions.example_action' } }

    it 'should delegate to the dispatcher' do
      expect(store)
        .to delegate_method(:dispatch)
        .to(store.send :dispatcher)
        .with_arguments(action)
    end

    wrap_context 'when the dispatcher has a subscribed listener' do
      it 'should call #update with the action' do
        store.dispatch(action)

        expect(listener).to have_received(:update).with(action)
      end
    end

    wrap_context 'when the store defines #build_dispatcher' do
      it 'should delegate to the dispatcher' do
        expect(store)
          .to delegate_method(:dispatch)
          .to(store.send :dispatcher)
          .with_arguments(action)
      end

      wrap_context 'when the dispatcher has a subscribed listener' do
        it 'should call #call with the action' do
          store.dispatch(action)

          expect(listener).to have_received(:call).with(action)
        end
      end
    end

    wrap_context 'when the store has a custom dispatcher' do
      it 'should delegate to the dispatcher' do
        expect(store)
          .to delegate_method(:dispatch)
          .to(store.send :dispatcher)
          .with_arguments(action)
      end

      wrap_context 'when the dispatcher has a subscribed listener' do
        it 'should call #update with the action' do
          store.dispatch(action)

          expect(listener).to have_received(:update).with(action)
        end
      end
    end
  end

  describe '#dispatcher' do
    include_examples 'should have private reader',
      :dispatcher,
      -> { an_instance_of Zinke::Dispatcher }

    wrap_context 'when the store defines #build_dispatcher' do
      it { expect(store.send :dispatcher).to be_a Spec::CustomDispatcher }
    end

    wrap_context 'when the store has a custom dispatcher' do
      it { expect(store.send :dispatcher).to be dispatcher }

      wrap_context 'when the store defines #build_dispatcher' do
        it { expect(store.send :dispatcher).to be dispatcher }
      end
    end
  end

  describe '#state' do
    include_examples 'should have reader', :state

    describe 'when initialized with no arguments' do
      let(:store) { described_class.new }

      it { expect(store.state).to be == {} }
    end

    describe 'when initialized with nil' do
      let(:state) { nil }

      it { expect(store.state).to be == {} }
    end

    describe 'when initialized with an object' do
      let(:state) { Object.new }

      it { expect(store.state).to be state }
    end

    describe 'when initialized with an empty hash' do
      let(:state) { {} }

      it { expect(store.state).to be == {} }
    end

    describe 'when initialized with a hash' do
      let(:state) do
        {
          era:   'Renaissance',
          genre: 'High Fantasy',
          magic: :high
        }
      end

      it { expect(store.state).to be == state }
    end

    describe 'when initialized with a hash with nested values' do
      let(:state) do
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

      it { expect(store.state).to be == state }
    end

    context 'when the store defines an initial state' do
      let(:described_class) { Spec::ExampleStore }
      let(:initial_state) do
        { magic_users: %w[Arcanist Magister Warlock] }
      end

      # rubocop:disable RSpec/DescribedClass
      example_class 'Spec::ExampleStore', Zinke::Store do |klass|
        state = initial_state

        klass.send :define_method, :initial_state, -> { state }
      end
      # rubocop:enable RSpec/DescribedClass

      describe 'when initialized with no arguments' do
        let(:store) { described_class.new }

        it { expect(store.state).to be == initial_state }
      end

      describe 'when initialized with nil' do
        let(:state) { nil }

        it { expect(store.state).to be == initial_state }
      end

      describe 'when initialized with an object' do
        let(:state) { Object.new }

        it { expect(store.state).to be state }
      end

      describe 'when initialized with an empty hash' do
        let(:state) { {} }

        it { expect(store.state).to be == {} }
      end

      describe 'when initialized with a hash' do
        let(:state) do
          {
            era:   'Renaissance',
            genre: 'High Fantasy',
            magic: :high
          }
        end

        it { expect(store.state).to be == state }
      end

      describe 'when initialized with a hash with nested values' do
        let(:state) do
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

        it { expect(store.state).to be == state }
      end
    end
  end

  describe '#state=' do
    let(:new_state) do
      {
        era:   'Renaissance',
        genre: 'High Fantasy',
        magic: :high
      }
    end

    include_examples 'should have private writer', :state=

    it 'should set the state' do
      expect { store.send :state=, new_state }
        .to change(store, :state)
        .to new_state
    end
  end

  describe '#subscribe' do
    it 'should delegate to the dispatcher' do
      expect(store)
        .to delegate_method(:subscribe)
        .to(store.send :dispatcher)
        .with_a_block
    end

    wrap_context 'when the store defines #build_dispatcher' do
      it 'should delegate to the dispatcher' do
        expect(store)
          .to delegate_method(:subscribe)
          .to(store.send :dispatcher)
          .with_a_block
      end
    end

    wrap_context 'when the store has a custom dispatcher' do
      it 'should delegate to the dispatcher' do
        expect(store)
          .to delegate_method(:subscribe)
          .to(store.send :dispatcher)
          .with_a_block
      end
    end
  end

  describe '#unsubscribe' do
    let(:action)   { { type: 'spec.actions.example_action' } }
    let(:listener) { instance_double(Zinke::Listeners::BaseListener) }

    it 'should delegate to the dispatcher' do
      expect(store)
        .to delegate_method(:unsubscribe)
        .to(store.send :dispatcher)
        .with_arguments(listener)
    end

    wrap_context 'when the dispatcher has a subscribed listener' do
      it 'should not call #update' do
        store.unsubscribe(listener)

        store.dispatch(action)

        expect(listener).not_to have_received(:update)
      end
    end

    wrap_context 'when the store defines #build_dispatcher' do
      let(:listener) { ->(_) {} }

      it 'should delegate to the dispatcher' do
        expect(store)
          .to delegate_method(:unsubscribe)
          .to(store.send :dispatcher)
          .with_arguments(listener)
      end

      wrap_context 'when the dispatcher has a subscribed listener' do
        it 'should not call #call' do
          store.unsubscribe(listener)

          store.dispatch(action)

          expect(listener).not_to have_received(:call)
        end
      end
    end

    wrap_context 'when the store has a custom dispatcher' do
      let(:listener) { ->(_) {} }

      it 'should delegate to the dispatcher' do
        expect(store)
          .to delegate_method(:unsubscribe)
          .to(store.send :dispatcher)
          .with_arguments(listener)
      end

      wrap_context 'when the dispatcher has a subscribed listener' do
        it 'should not call #update' do
          store.unsubscribe(listener)

          store.dispatch(action)

          expect(listener).not_to have_received(:update)
        end
      end
    end
  end
end
