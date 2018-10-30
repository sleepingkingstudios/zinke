# frozen_string_literal: true

require 'zinke/reducer'
require 'zinke/store'

RSpec.describe Zinke::Reducer do
  let(:described_class) { Spec::ExampleReducer }
  let(:initial_state)   { { value: 5 } }
  let(:store)           { Spec::ExampleStore.new(initial_state) }

  example_constant 'Spec::ExampleReducer' do
    Module.new do
      include Zinke::Reducer

      def add(amount)
        state.merge(value: state[:value] + amount)
      end

      def divide_by_zero(_state, _action)
        nil
      end

      def multiply(state, action)
        state.merge(value: state[:value] * action[:amount])
      end
    end
  end

  example_class 'Spec::ExampleStore', Zinke::Store do |klass|
    klass.include Spec::ExampleReducer
  end

  describe '::update' do
    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:update)
        .with(1..2)
        .arguments.and_a_block
    end

    describe 'with a block' do
      let(:action_type) { 'spec.actions.add_action' }

      context 'when a non-matching action is dispatched' do
        let(:action) { { type: 'spec.actions.subtract_action' } }

        it 'should not yield' do
          expect do |block|
            described_class.update(action_type, &block)

            store.dispatch(action)
          end
            .not_to yield_control
        end

        it 'should not update the state' do
          described_class.update(action_type) do |state, action|
            # :nocov:
            state.merge(value: state[:value] + action[:amount])
            # :nocov:
          end

          expect { store.dispatch(action) }.not_to change(store, :state)
        end
      end

      context 'when a matching action is dispatched' do
        let(:action) { { type: action_type, amount: 10 } }

        it 'should yield the state and action' do
          expect do |block|
            described_class.update(action_type, &block)

            store.dispatch(action)
          end
            .to yield_with_args(be == initial_state, action)
        end

        # rubocop:disable RSpec/ExampleLength
        it 'should update the state' do
          described_class.update(action_type) do |state, action|
            state.merge(value: state[:value] + action[:amount])
          end

          expect { store.dispatch(action) }
            .to change(store, :state)
            .to(satisfy { |state| state[:value] == 15 })
        end
        # rubocop:enable RSpec/ExampleLength
      end
    end

    describe 'with a block referencing an instance method' do
      let(:action_type) { 'spec.actions.add_action' }

      context 'when a matching action is dispatched' do
        let(:action) { { type: action_type, amount: 10 } }

        # rubocop:disable RSpec/ExampleLength
        it 'should update the state' do
          described_class.update(action_type) do |_state, action|
            add(action[:amount])
          end

          expect { store.dispatch(action) }
            .to change(store, :state)
            .to(satisfy { |state| state[:value] == 15 })
        end
        # rubocop:enable RSpec/ExampleLength
      end
    end

    describe 'with a block returning nil' do
      let(:action_type) { 'spec.actions.add_action' }

      context 'when a non-matching action is dispatched' do
        let(:action) { { type: 'spec.actions.subtract_action' } }

        it 'should not yield' do
          expect do |block|
            described_class.update(action_type, &block)

            store.dispatch(action)
          end
            .not_to yield_control
        end

        it 'should not update the state' do
          described_class.update(action_type) { nil }

          expect { store.dispatch(action) }.not_to change(store, :state)
        end
      end

      context 'when a matching action is dispatched' do
        let(:action) { { type: action_type } }

        it 'should yield the state and action' do
          expect do |block|
            described_class.update(action_type, &block)

            store.dispatch(action)
          end
            .to yield_with_args(be == initial_state, action)
        end

        it 'should not update the state' do
          described_class.update(action_type) { nil }

          expect { store.dispatch(action) }.not_to change(store, :state)
        end
      end
    end

    describe 'with a method name' do
      let(:method_name) { :multiply }
      let(:action_type) { 'spec.actions.multiply_action' }

      context 'when a non-matching action is dispatched' do
        let(:action) { { type: 'spec.actions.divide_action' } }

        it 'should not call the method' do
          described_class.update(action_type, method_name)

          allow(store).to receive(method_name)

          store.dispatch(action)

          expect(store).not_to have_received(method_name)
        end

        it 'should not update the state' do
          described_class.update(action_type, method_name)

          expect { store.dispatch(action) }.not_to change(store, :state)
        end
      end

      context 'when a matching action is dispatched' do
        let(:action) { { type: action_type, amount: 2 } }

        # rubocop:disable RSpec/ExampleLength
        it 'should call the method' do
          described_class.update(action_type, method_name)

          allow(store).to receive(method_name)

          previous_state = store.state

          store.dispatch(action)

          expect(store)
            .to have_received(method_name)
            .with(previous_state, action)
        end
        # rubocop:enable RSpec/ExampleLength

        it 'should update the state' do
          described_class.update(action_type, method_name)

          expect { store.dispatch(action) }
            .to change(store, :state)
            .to(satisfy { |state| state[:value] == 10 })
        end
      end
    end

    describe 'with a method name returning nil' do
      let(:method_name) { :divide_by_zero }
      let(:action_type) { 'spec.actions.divide_action' }

      context 'when a non-matching action is dispatched' do
        let(:action) { { type: 'spec.actions.square_root_action' } }

        it 'should not call the method' do
          described_class.update(action_type, method_name)

          allow(store).to receive(method_name)

          store.dispatch(action)

          expect(store).not_to have_received(method_name)
        end

        it 'should not update the state' do
          described_class.update(action_type, method_name)

          expect { store.dispatch(action) }.not_to change(store, :state)
        end
      end

      context 'when a matching action is dispatched' do
        let(:action) { { type: action_type } }

        # rubocop:disable RSpec/ExampleLength
        it 'should call the method' do
          described_class.update(action_type, method_name)

          allow(store).to receive(method_name)

          previous_state = store.state

          store.dispatch(action)

          expect(store)
            .to have_received(method_name)
            .with(previous_state, action)
        end
        # rubocop:enable RSpec/ExampleLength

        it 'should not update the state' do
          described_class.update(action_type, method_name)

          expect { store.dispatch(action) }.not_to change(store, :state)
        end
      end
    end
  end
end
