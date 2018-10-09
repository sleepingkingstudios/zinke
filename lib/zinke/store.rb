# frozen_string_literal: true

require 'hamster'

require 'zinke/immutable'

module Zinke
  # Encapsulates a single, immutable state.
  class Store
    def initialize(initial_state = nil)
      guard_initial_state!(initial_state)

      @state = Zinke::Immutable.from_object(initial_state || {})
    end

    attr_reader :state

    protected

    attr_writer :state

    private

    def guard_initial_state!(value)
      return if value.nil?
      return if value.is_a?(Hash)
      return if value.is_a?(Hamster::Hash)

      message = "initial state must be a Hash or nil, but was #{value.inspect}"

      raise ArgumentError, message, caller[1..-1]
    end
  end
end
