# frozen_string_literal: true

require 'zinke/listeners'
require 'zinke/listeners/base_listener'

module Zinke::Listeners
  # Helper class encapsulating an action handler. Checks the action type against
  # an expected value and only executes the action handler on an equal action
  # type.
  #
  # @see Zinke::Store::Dispatcher#subscribe
  class TypeListener < Zinke::Listeners::BaseListener
    # @param action_type [String, Symbol] The expected action type. On an
    #   update, the definition will be called only if the :type of the action
    #   is equal to the expected action type.
    # @yieldparam action [Hash] The dispatched action object.
    def initialize(action_type:, &block)
      super(&block)

      @action_type = action_type
    end

    # @return [String, Symbol] the expected action type.
    attr_reader :action_type

    # Calls the definition with the action if the action's :type property
    # is equal to the expected action type.
    #
    # (see Zinke::Listeners::BaseListener#update)
    def update(action)
      return unless action[:type] == action_type

      super
    end
  end
end
