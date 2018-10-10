# frozen_string_literal: true

require 'support/calculator'

RSpec.describe Spec::Calculator do
  shared_context 'when the calculator is on' do
    before(:example) { calculator.turn_on }
  end

  shared_context 'when the calculator has value' do |initial_value|
    before(:example) do
      calculator
        .turn_off
        .turn_on
        .add(initial_value)
    end
  end

  subject(:calculator) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#add' do
    it { expect(calculator).to respond_to(:add).with(1).argument }

    it { expect(calculator.add 5).to be calculator }

    it { expect { calculator.add 5 }.not_to change(calculator, :value) }

    wrap_context 'when the calculator is on' do
      it { expect(calculator.add 5).to be calculator }

      it 'should add 5 to the value' do
        expect { calculator.add 5 }.to change(calculator, :value).to(5)
      end
    end

    wrap_context 'when the calculator has value', 50.0 do
      it 'should add 5 to the value' do
        expect { calculator.add 5 }.to change(calculator, :value).to(55)
      end
    end
  end

  describe '#divide' do
    it { expect(calculator).to respond_to(:divide).with(1).argument }

    it { expect(calculator.divide 2).to be calculator }

    it { expect { calculator.divide 2 }.not_to change(calculator, :value) }

    describe 'with zero' do
      it { expect(calculator.divide 0).to be calculator }

      it { expect { calculator.divide 0 }.not_to change(calculator, :value) }
    end

    wrap_context 'when the calculator is on' do
      it { expect(calculator.divide 2).to be calculator }

      it { expect { calculator.divide 2 }.not_to change(calculator, :value) }

      describe 'with zero' do
        it { expect(calculator.divide 0).to be calculator }

        it { expect { calculator.divide 0 }.not_to change(calculator, :value) }
      end
    end

    wrap_context 'when the calculator has value', 50.0 do
      it 'should divide the value by 2' do
        expect { calculator.divide 2 }.to change(calculator, :value).to(25)
      end

      describe 'with zero' do
        it { expect(calculator.divide 0).to be calculator }

        it { expect { calculator.divide 0 }.not_to change(calculator, :value) }
      end
    end
  end

  describe '#multiply' do
    it { expect(calculator).to respond_to(:multiply).with(1).argument }

    it { expect(calculator.multiply 2).to be calculator }

    it { expect { calculator.multiply 2 }.not_to change(calculator, :value) }

    wrap_context 'when the calculator is on' do
      it { expect(calculator.multiply 2).to be calculator }

      it { expect { calculator.multiply 2 }.not_to change(calculator, :value) }
    end

    wrap_context 'when the calculator has value', 50.0 do
      it 'should multiply the value by 2' do
        expect { calculator.multiply 2 }.to change(calculator, :value).to(100)
      end
    end
  end

  describe '#on?' do
    it { expect(calculator).to have_predicate(:on?).with_value(false) }

    wrap_context 'when the calculator is on' do
      it { expect(calculator.on?).to be true }
    end
  end

  describe '#state' do
    let(:expected) do
      {
        on:    false,
        value: nil
      }
    end

    it { expect(calculator).to have_reader :state }

    it { expect(calculator.state).to be_a Hamster::Hash }

    it { expect(calculator.state).to be == expected }
  end

  describe '#subtract' do
    it { expect(calculator).to respond_to(:subtract).with(1).argument }

    it { expect(calculator.subtract 5).to be calculator }

    it { expect { calculator.subtract 5 }.not_to change(calculator, :value) }

    wrap_context 'when the calculator is on' do
      it { expect(calculator.subtract 5).to be calculator }

      it 'should subtract 5 from the value' do
        expect { calculator.subtract 5 }.to change(calculator, :value).to(-5)
      end
    end

    wrap_context 'when the calculator has value', 50.0 do
      it 'should subtract 5 from the value' do
        expect { calculator.subtract 5 }.to change(calculator, :value).to(45)
      end
    end
  end

  describe '#turn_off' do
    it { expect(calculator).to respond_to(:turn_off).with(0).arguments }

    it { expect(calculator.turn_off).to be calculator }

    it { expect { calculator.turn_off }.not_to change(calculator, :on?) }

    wrap_context 'when the calculator is on' do
      it { expect(calculator.turn_off).to be calculator }

      it 'should turn off the calculator' do
        expect { calculator.turn_off }.to change(calculator, :on?).to be false
      end
    end
  end

  describe '#turn_on' do
    it { expect(calculator).to respond_to(:turn_on).with(0).arguments }

    it { expect(calculator.turn_on).to be calculator }

    it 'should turn on the calculator' do
      expect { calculator.turn_on }.to change(calculator, :on?).to be true
    end

    wrap_context 'when the calculator is on' do
      it { expect(calculator.turn_on).to be calculator }

      it { expect { calculator.turn_on }.not_to change(calculator, :on?) }
    end

    wrap_context 'when the calculator has value', 50.0 do
      it { expect(calculator.turn_on).to be calculator }

      it { expect { calculator.turn_on }.not_to change(calculator, :on?) }

      it { expect { calculator.turn_on }.not_to change(calculator, :value) }
    end
  end

  describe '#value' do
    it { expect(calculator).to have_reader(:value).with_value(nil) }

    wrap_context 'when the calculator is on' do
      it { expect(calculator.value).to be == 0.0 }
    end

    wrap_context 'when the calculator has value', 50.0 do
      it { expect(calculator.value).to be == 50.0 }
    end
  end
end
