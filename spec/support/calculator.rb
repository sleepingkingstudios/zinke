# frozen_string_literal: true

require 'zinke/store'

require 'support/calculator/operator_actions'
require 'support/calculator/operator_reducer'
require 'support/calculator/power_actions'
require 'support/calculator/power_reducer'

module Spec
  class Calculator
    class Store < Zinke::Store
      include Spec::Calculator::OperatorReducer
      include Spec::Calculator::PowerReducer
    end

    def initialize
      @store = Spec::Calculator::Store.new(initial_state)
    end

    def add(amount)
      return self unless on?

      @store.dispatch Spec::Calculator::OperatorActions.add(amount)

      self
    end

    def divide(amount)
      return self unless on?

      @store.dispatch Spec::Calculator::OperatorActions.divide(amount)

      self
    end

    def multiply(amount)
      return self unless on?

      @store.dispatch Spec::Calculator::OperatorActions.multiply(amount)

      self
    end

    def on?
      state.get(:on)
    end

    def state
      @store.state
    end

    def subtract(amount)
      return self unless on?

      @store.dispatch Spec::Calculator::OperatorActions.subtract(amount)

      self
    end

    def turn_on
      return self if on?

      @store.dispatch Spec::Calculator::PowerActions.turn_on

      self
    end

    def turn_off
      @store.dispatch Spec::Calculator::PowerActions.turn_off

      self
    end

    def value
      state.get(:value)
    end

    private

    def initial_state
      {
        on:    false,
        value: nil
      }
    end
  end
end
