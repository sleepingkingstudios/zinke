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

  subject(:calculator) { described_class.new(output) }

  let(:output) { StringIO.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }

    describe 'with no arguments' do
      let(:calculator) { described_class.new }

      it { expect(calculator.output).to be STDOUT }
    end
  end

  describe '#add' do
    it { expect(calculator).to respond_to(:add).with(1).argument }

    it { expect(calculator.add 5).to be calculator }

    it { expect { calculator.add 5 }.not_to change(calculator, :value) }

    it { expect { calculator.add 5 }.not_to change(calculator, :display) }

    it { expect { calculator.add 5 }.not_to change(output, :string) }

    wrap_context 'when the calculator is on' do
      it { expect(calculator.add 5).to be calculator }

      it 'should add 5 to the value' do
        expect { calculator.add 5 }.to change(calculator, :value).to(5)
      end

      it 'should update the display' do
        expect { calculator.add 5 }
          .to change(calculator, :display)
          .to be == '0.0 + 5.0 = 5.0'
      end

      it 'should update the output' do
        expect { calculator.add 5 }
          .to change(output, :string)
          .to be == "0.0\n0.0 + 5.0 = 5.0\n"
      end
    end

    wrap_context 'when the calculator has value', 50.0 do
      it 'should add 5 to the value' do
        expect { calculator.add 5 }.to change(calculator, :value).to(55)
      end

      it 'should update the display' do
        expect { calculator.add 5 }
          .to change(calculator, :display)
          .to be == '50.0 + 5.0 = 55.0'
      end

      it 'should update the output' do
        expect { calculator.add 5 }
          .to change(output, :string)
          .to be == "0.0\n0.0 + 50.0 = 50.0\n50.0 + 5.0 = 55.0\n"
      end
    end
  end

  describe '#display' do
    it { expect(calculator).to have_reader(:display).with_value(nil) }

    wrap_context 'when the calculator is on' do
      it { expect(calculator.display).to be == '0.0' }
    end

    wrap_context 'when the calculator has value', 50.0 do
      it { expect(calculator.display).to be == '0.0 + 50.0 = 50.0' }
    end
  end

  describe '#divide' do
    it { expect(calculator).to respond_to(:divide).with(1).argument }

    it { expect(calculator.divide 2).to be calculator }

    it { expect { calculator.divide 2 }.not_to change(calculator, :value) }

    it { expect { calculator.divide 2 }.not_to change(calculator, :display) }

    it { expect { calculator.divide 2 }.not_to change(output, :string) }

    describe 'with zero' do
      it { expect(calculator.divide 0).to be calculator }

      it { expect { calculator.divide 0 }.not_to change(calculator, :value) }

      it { expect { calculator.divide 0 }.not_to change(calculator, :display) }

      it { expect { calculator.divide 0 }.not_to change(output, :string) }
    end

    wrap_context 'when the calculator is on' do
      it { expect(calculator.divide 2).to be calculator }

      it { expect { calculator.divide 2 }.not_to change(calculator, :value) }

      it 'should update the display' do
        expect { calculator.divide 2 }
          .to change(calculator, :display)
          .to be == '0.0 / 2.0 = 0.0'
      end

      it 'should update the output' do
        expect { calculator.divide 2 }
          .to change(output, :string)
          .to be == "0.0\n0.0 / 2.0 = 0.0\n"
      end

      describe 'with zero' do
        it { expect(calculator.divide 0).to be calculator }

        it { expect { calculator.divide 0 }.not_to change(calculator, :value) }

        it 'should update the display' do
          expect { calculator.divide 0 }
            .to change(calculator, :display)
            .to be == 'DIV / 0'
        end

        it 'should update the output' do
          expect { calculator.divide 0 }
            .to change(output, :string)
            .to be == "0.0\nDIV / 0\n"
        end
      end
    end

    wrap_context 'when the calculator has value', 50.0 do
      it 'should divide the value by 2' do
        expect { calculator.divide 2 }.to change(calculator, :value).to(25)
      end

      it 'should update the display' do
        expect { calculator.divide 2 }
          .to change(calculator, :display)
          .to be == '50.0 / 2.0 = 25.0'
      end

      it 'should update the output' do
        expect { calculator.divide 2 }
          .to change(output, :string)
          .to be == "0.0\n0.0 + 50.0 = 50.0\n50.0 / 2.0 = 25.0\n"
      end

      describe 'with zero' do
        it { expect(calculator.divide 0).to be calculator }

        it { expect { calculator.divide 0 }.not_to change(calculator, :value) }

        it 'should update the display' do
          expect { calculator.divide 0 }
            .to change(calculator, :display)
            .to be == 'DIV / 0'
        end

        it 'should update the output' do
          expect { calculator.divide 0 }
            .to change(output, :string)
            .to be == "0.0\n0.0 + 50.0 = 50.0\nDIV / 0\n"
        end
      end
    end
  end

  describe '#multiply' do
    it { expect(calculator).to respond_to(:multiply).with(1).argument }

    it { expect(calculator.multiply 2).to be calculator }

    it { expect { calculator.multiply 2 }.not_to change(calculator, :value) }

    it { expect { calculator.multiply 2 }.not_to change(calculator, :display) }

    it { expect { calculator.multiply 2 }.not_to change(output, :string) }

    wrap_context 'when the calculator is on' do
      it { expect(calculator.multiply 2).to be calculator }

      it { expect { calculator.multiply 2 }.not_to change(calculator, :value) }

      it 'should update the display' do
        expect { calculator.multiply 2 }
          .to change(calculator, :display)
          .to be == '0.0 * 2.0 = 0.0'
      end

      it 'should update the output' do
        expect { calculator.multiply 2 }
          .to change(output, :string)
          .to be == "0.0\n0.0 * 2.0 = 0.0\n"
      end
    end

    wrap_context 'when the calculator has value', 50.0 do
      it 'should multiply the value by 2' do
        expect { calculator.multiply 2 }.to change(calculator, :value).to(100)
      end

      it 'should update the display' do
        expect { calculator.multiply 2 }
          .to change(calculator, :display)
          .to be == '50.0 * 2.0 = 100.0'
      end

      it 'should update the output' do
        expect { calculator.multiply 2 }
          .to change(output, :string)
          .to be == "0.0\n0.0 + 50.0 = 50.0\n50.0 * 2.0 = 100.0\n"
      end
    end
  end

  describe '#on?' do
    it { expect(calculator).to have_predicate(:on?).with_value(false) }

    wrap_context 'when the calculator is on' do
      it { expect(calculator.on?).to be true }
    end
  end

  describe '#output' do
    it { expect(calculator).to have_reader(:output).with_value(output) }

    wrap_context 'when the calculator is on' do
      it { expect(calculator.output.string).to be == "0.0\n" }
    end

    wrap_context 'when the calculator has value', 50.0 do
      it 'should be the display history' do
        expect(calculator.output.string).to be == "0.0\n0.0 + 50.0 = 50.0\n"
      end
    end
  end

  describe '#state' do
    let(:expected) do
      {
        on:      false,
        display: nil,
        value:   nil
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

    it { expect { calculator.subtract 5 }.not_to change(calculator, :display) }

    it { expect { calculator.subtract 5 }.not_to change(output, :string) }

    wrap_context 'when the calculator is on' do
      it { expect(calculator.subtract 5).to be calculator }

      it 'should subtract 5 from the value' do
        expect { calculator.subtract 5 }.to change(calculator, :value).to(-5)
      end

      it 'should update the display' do
        expect { calculator.subtract 5 }
          .to change(calculator, :display)
          .to be == '0.0 - 5.0 = -5.0'
      end

      it 'should update the output' do
        expect { calculator.subtract 5 }
          .to change(output, :string)
          .to be == "0.0\n0.0 - 5.0 = -5.0\n"
      end
    end

    wrap_context 'when the calculator has value', 50.0 do
      it 'should subtract 5 from the value' do
        expect { calculator.subtract 5 }.to change(calculator, :value).to(45)
      end

      it 'should update the display' do
        expect { calculator.subtract 5 }
          .to change(calculator, :display)
          .to be == '50.0 - 5.0 = 45.0'
      end

      it 'should update the output' do
        expect { calculator.subtract 5 }
          .to change(output, :string)
          .to be == "0.0\n0.0 + 50.0 = 50.0\n50.0 - 5.0 = 45.0\n"
      end
    end
  end

  describe '#turn_off' do
    it { expect(calculator).to respond_to(:turn_off).with(0).arguments }

    it { expect(calculator.turn_off).to be calculator }

    it { expect { calculator.turn_off }.not_to change(calculator, :on?) }

    it { expect { calculator.turn_off }.not_to change(calculator, :display) }

    it { expect { calculator.turn_off }.not_to change(output, :string) }

    wrap_context 'when the calculator is on' do
      it { expect(calculator.turn_off).to be calculator }

      it 'should turn off the calculator' do
        expect { calculator.turn_off }.to change(calculator, :on?).to be false
      end

      it 'should clear the value' do
        expect { calculator.turn_off }.to change(calculator, :value).to be nil
      end

      it 'should update the display' do
        expect { calculator.turn_off }
          .to change(calculator, :display)
          .to be nil
      end

      it { expect { calculator.turn_off }.not_to change(output, :string) }
    end

    wrap_context 'when the calculator has value', 50.0 do
      it { expect(calculator.turn_off).to be calculator }

      it 'should turn off the calculator' do
        expect { calculator.turn_off }.to change(calculator, :on?).to be false
      end

      it 'should clear the value' do
        expect { calculator.turn_off }.to change(calculator, :value).to be nil
      end

      it 'should update the display' do
        expect { calculator.turn_off }
          .to change(calculator, :display)
          .to be nil
      end

      it { expect { calculator.turn_off }.not_to change(output, :string) }
    end
  end

  describe '#turn_on' do
    it { expect(calculator).to respond_to(:turn_on).with(0).arguments }

    it { expect(calculator.turn_on).to be calculator }

    it 'should turn on the calculator' do
      expect { calculator.turn_on }.to change(calculator, :on?).to be true
    end

    it 'should set the value' do
      expect { calculator.turn_on }.to change(calculator, :value).to be == 0
    end

    it 'should update the display' do
      expect { calculator.turn_on }
        .to change(calculator, :display)
        .to be == '0.0'
    end

    it 'should update the output' do
      expect { calculator.turn_on }
        .to change(output, :string)
        .to be == "0.0\n"
    end

    wrap_context 'when the calculator is on' do
      it { expect(calculator.turn_on).to be calculator }

      it { expect { calculator.turn_on }.not_to change(calculator, :on?) }

      it { expect { calculator.turn_on }.not_to change(calculator, :value) }

      it { expect { calculator.turn_on }.not_to change(calculator, :display) }

      it { expect { calculator.turn_on }.not_to change(output, :string) }
    end

    wrap_context 'when the calculator has value', 50.0 do
      it { expect(calculator.turn_on).to be calculator }

      it { expect { calculator.turn_on }.not_to change(calculator, :on?) }

      it { expect { calculator.turn_on }.not_to change(calculator, :value) }

      it { expect { calculator.turn_on }.not_to change(calculator, :display) }

      it { expect { calculator.turn_on }.not_to change(output, :string) }
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
