# frozen_string_literal: true

require 'zinke/reducer'

require 'support/calculator/power_actions'

module Spec
  class Calculator
    module PowerReducer
      include Zinke::Reducer

      update Spec::Calculator::PowerActions::TURN_OFF do |state, _action|
        state.merge(on: false, value: nil)
      end

      update Spec::Calculator::PowerActions::TURN_ON, :turn_on

      def turn_on(state, _action)
        state.merge(on: true, value: 0.0)
      end
    end
  end
end
