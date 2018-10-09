# frozen_string_literal: true

require 'zinke/immutable'

RSpec.describe Zinke::Immutable do
  shared_context 'with a complex data structure' do
    let(:immutable_data) do
      Hamster::Hash.new(
        cities: Hamster::Vector.new(
          [
            Hamster::Hash.new(
              name:     'The Free City of Caldera',
              location: 'in a volcano'
            ),
            Hamster::Hash.new(
              name:     "Grove of Star's Light",
              location: 'probably a forest'
            ),
            Hamster::Hash.new(
              name:     'Winterheart',
              location: 'somewhere cold'
            )
          ]
        ),
        era:   'Renaissance',
        genre: 'High Fantasy',
        magic: :high,
        spells: Hamster::Set.new(
          [
            Hamster::Hash.new(name: 'fireball'),
            Hamster::Hash.new(name: 'lightning bolt'),
            Hamster::Hash.new(name: 'magic missile')
          ]
        ),
        weapons: Hamster::Hash.new(
          bows: Hamster::Set.new(%w[crossbow longbow shortbow]),
          polearms: Hamster::Vector.new(%w[halberd pike spear]),
          swords: Hamster::Hash.new(
            japanese: Hamster::Set.new(%w[shoto daito tachi])
          )
        )
      )
    end
  end

  describe '::dig' do
    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:dig)
        .with(1).argument
        .and_unlimited_arguments
    end

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.dig nil }
          .to raise_error ArgumentError,
            'argument must be an immutable data structure'
      end
    end

    describe 'with an empty hash' do
      let(:immutable) { Hamster::Hash.new }

      it { expect(described_class.dig immutable, :seven).to be nil }

      it { expect(described_class.dig immutable, :seven, 8, :nine).to be nil }
    end

    describe 'with a hash with items' do
      let(:immutable) do
        Hamster::Hash.new(
          english:  'shortsword',
          german:   'einhänder',
          japanese: 'shoto'
        )
      end
      let(:error_message) do
        'String does not have #dig method'
      end

      it { expect(described_class.dig immutable, :seven).to be nil }

      it { expect(described_class.dig immutable, :seven, 8, :nine).to be nil }

      it { expect(described_class.dig immutable, :german).to be == 'einhänder' }

      it 'should raise an error' do
        expect { described_class.dig immutable, :german, 1, :bavarian }
          .to raise_error TypeError, error_message
      end
    end

    describe 'with a hash of data objects' do
      include_context 'with a complex data structure'

      let(:immutable) { immutable_data[:weapons] }
      let(:error_message) do
        'Hamster::Set does not have #dig method'
      end

      it { expect(described_class.dig immutable, :seven).to be nil }

      it { expect(described_class.dig immutable, :seven, 8, :nine).to be nil }

      it 'should return the item' do
        expect(described_class.dig immutable, :swords)
          .to be == immutable[:swords]
      end

      it 'should return the nested item' do
        expect(described_class.dig immutable, :swords, :japanese)
          .to be == immutable[:swords][:japanese]
      end

      it 'should raise an error' do
        expect { described_class.dig immutable, :swords, :japanese, 0 }
          .to raise_error TypeError, error_message
      end
    end

    describe 'with an empty set' do
      let(:immutable) { Hamster::Set.new }
      let(:error_message) do
        'Hamster::Set does not have #dig method'
      end

      it 'should raise an error' do
        expect { described_class.dig immutable, 7 }
          .to raise_error TypeError, error_message
      end
    end

    describe 'with a set with items' do
      let(:immutable) { Hamster::Set.new(%w[one two three]) }
      let(:error_message) do
        'Hamster::Set does not have #dig method'
      end

      it 'should raise an error' do
        expect { described_class.dig immutable, 7 }
          .to raise_error TypeError, error_message
      end
    end

    describe 'with a set of data objects' do
      include_context 'with a complex data structure'

      let(:immutable) { immutable_data[:spells] }
      let(:error_message) do
        'Hamster::Set does not have #dig method'
      end

      it 'should raise an error' do
        expect { described_class.dig immutable, 7 }
          .to raise_error TypeError, error_message
      end
    end

    describe 'with an empty vector' do
      let(:immutable) { Hamster::Vector.new }

      it { expect(described_class.dig immutable, 7).to be nil }

      it { expect(described_class.dig immutable, 7, :eight, 9).to be nil }
    end

    describe 'with a vector with items' do
      let(:immutable) { Hamster::Vector.new(%w[one two three]) }
      let(:error_message) do
        'String does not have #dig method'
      end

      it { expect(described_class.dig immutable, 7).to be nil }

      it { expect(described_class.dig immutable, 7, :eight, 9).to be nil }

      it { expect(described_class.dig immutable, 1).to be == 'two' }

      it 'should raise an error' do
        expect { described_class.dig immutable, 1, :two, 3 }
          .to raise_error TypeError, error_message
      end
    end

    describe 'with a vector of data objects' do
      include_context 'with a complex data structure'

      let(:immutable) { immutable_data[:cities] }
      let(:error_message) do
        'String does not have #dig method'
      end

      it { expect(described_class.dig immutable, 7).to be nil }

      it { expect(described_class.dig immutable, 7, :eight, 9).to be nil }

      it 'should return the item' do
        expect(described_class.dig immutable, 1).to be == immutable[1]
      end

      it 'should return the nested item' do
        expect(described_class.dig immutable, 1, :name)
          .to be == immutable[1][:name]
      end

      it 'should raise an error' do
        expect { described_class.dig immutable, 1, :name, :nickname }
          .to raise_error TypeError, error_message
      end
    end
  end
end
