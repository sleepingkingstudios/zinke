# frozen_string_literal: true

require 'zinke/listeners'

module Zinke::Listeners
  # Helper class encapsulating an action handler.
  #
  # @see Zinke::Store::Dispatcher#subscribe
  class BaseListener
    MISSING_DEFINITION_ERROR = 'must provide a block'
    private_constant :MISSING_DEFINITION_ERROR

    # @yieldparam action [Hash] The dispatched action object.
    def initialize(&block)
      raise ArgumentError, MISSING_DEFINITION_ERROR unless block_given?

      @definition = block
    end

    # Calls the definition with the action.
    #
    # @param action [Hash] The action object. By convention, should be a Hash
    #   with a :type key and a String or Symbol value, and can have other keys
    #   and values representing additional data.
    #
    # @return [Object] The value returned by calling the definition.
    #
    # @see Zinke::Store::Dispatcher#dispatch
    def update(action)
      @definition.call(action)
    end
  end
end
