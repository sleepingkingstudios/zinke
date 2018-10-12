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

    def initialize(output = STDOUT)
      @output = output
      @store  = Spec::Calculator::Store.new(initial_state)

      @store.subscribe { update_display }
    end

    attr_reader :output

    def add(amount)
      return self unless on?

      @store.dispatch Spec::Calculator::OperatorActions.add(amount)

      self
    end

    def display
      state[:display]
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
      state[:on]
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
      state[:value]
    end

    private

    def initial_state
      {
        on:      false,
        display: nil,
        value:   nil
      }
    end

    def update_display
      return unless on?

      output.puts(display)
    end
  end
end
