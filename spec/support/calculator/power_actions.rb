# frozen_string_literal: true

module Spec
  class Calculator
    module PowerActions
      TURN_OFF = 'spec.actions.power.off'
      TURN_ON  = 'spec.actions.power.on'

      def self.turn_off
        { type: TURN_OFF }
      end

      def self.turn_on
        { type: TURN_ON }
      end
    end
  end
end
