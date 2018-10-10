# frozen_string_literal: true

module Spec
  class Calculator
    module OperatorActions
      ADD      = 'spec.actions.operator.add'
      DIVIDE   = 'spec.actions.operator.divide'
      MULTIPLY = 'spec.actions.operator.multiply'
      SUBTRACT = 'spec.actions.operator.subtract'

      def self.add(amount)
        {
          type:   ADD,
          amount: amount
        }
      end

      def self.divide(amount)
        {
          type:   DIVIDE,
          amount: amount
        }
      end

      def self.multiply(amount)
        {
          type:   MULTIPLY,
          amount: amount
        }
      end

      def self.subtract(amount)
        {
          type:   SUBTRACT,
          amount: amount
        }
      end
    end
  end
end
