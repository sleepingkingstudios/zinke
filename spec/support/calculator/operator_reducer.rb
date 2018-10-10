# frozen_string_literal: true

require 'zinke/reducer'

require 'support/calculator/operator_actions'

module Spec
  class Calculator
    module OperatorReducer
      include Zinke::Reducer

      update Spec::Calculator::OperatorActions::ADD do |state, action|
        amount    = action[:amount]
        old_value = state.get(:value)
        new_value = add_values(old_value, action[:amount])
        display   = "#{old_value} + #{amount.to_f} = #{new_value}"

        state.merge(display: display, value: new_value)
      end

      update Spec::Calculator::OperatorActions::SUBTRACT do |state, action|
        amount    = action[:amount]
        old_value = state.get(:value)
        new_value = old_value - amount
        display   = "#{old_value} - #{amount.to_f} = #{new_value}"

        state.merge(display: display, value: new_value)
      end

      update Spec::Calculator::OperatorActions::MULTIPLY, :multiply
      update Spec::Calculator::OperatorActions::DIVIDE,   :divide

      def divide(state, action)
        amount = action[:amount]

        return state.merge(display: 'DIV / 0') if amount.zero?

        old_value = state.get(:value)
        new_value = old_value / amount
        display   = "#{old_value} / #{amount.to_f} = #{new_value}"

        state.merge(display: display, value: new_value)
      end

      def multiply(state, action)
        amount    = action[:amount]
        old_value = state.get(:value)
        new_value = multiply_values(state.get(:value), amount)
        display   = "#{old_value} * #{amount.to_f} = #{new_value}"

        state.merge(display: display, value: new_value)
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
