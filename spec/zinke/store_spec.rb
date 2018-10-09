# frozen_string_literal: true

require 'zinke/store'

RSpec.describe Zinke::Store do
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
end
