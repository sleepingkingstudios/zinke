# frozen_string_literal: true

require 'zinke/reducer'

require 'support/calculator/operator_actions'

module Spec
  class Calculator
    module OperatorReducer
      include Zinke::Reducer

      update Spec::Calculator::OperatorActions::ADD do |state, action|
        state.put(:value) { add_values(state.get(:value), action[:amount]) }
      end

      update Spec::Calculator::OperatorActions::SUBTRACT do |state, action|
        state.put(:value) { state.get(:value) - action[:amount] }
      end

      update Spec::Calculator::OperatorActions::MULTIPLY, :multiply
      update Spec::Calculator::OperatorActions::DIVIDE,   :divide

      def divide(state, action)
        amount = action[:amount]

        return state if amount.zero?

        state.put(:value) { state.get(:value) / amount }
      end

      def multiply(state, action)
        state.put(:value, multiply_values(state.get(:value), action[:amount]))
      end

      private

      def add_values(*values)
        values.reduce(&:+)
      end

      def multiply_values(*values)
        values.reduce(&:*)
      end
    end
  end
end
