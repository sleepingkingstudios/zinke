# frozen_string_literal: true

require 'observer'

require 'hamster'

require 'zinke/immutable'

module Zinke
  # Encapsulates a single, immutable state.
  class Store
    # Helper class implementing Observable and providing a less cryptic error
    # message when adding a listener while dispatching an action.
    class Dispatcher
      ITERATION_ERROR = "can't add a new key into hash during iteration"
      LISTENER_ERROR  = "can't add a listener while dispatching an action"

      include Observable

      def dispatch(action)
        changed

        notify_observers(action)
      rescue RuntimeError => exception
        raise unless exception.message == ITERATION_ERROR

        raise LISTENER_ERROR
      end

      def subscribe(action_type = nil, definition:)
        listener = Listener.new(action_type, definition: definition)

        add_observer(listener)

        listener
      end

      def unsubscribe(listener)
        delete_observer(listener)
      end
    end

    # Helper class encapsulating an action handler. Optionally provides basic
    # equality check against an expected action type.
    class Listener
      def initialize(action_type = nil, definition:)
        @action_type = action_type
        @definition  = definition
      end

      def update(action)
        return unless @action_type.nil? || @action_type == action[:type]

        @definition.call(action)
      end
    end

    def initialize(initial_state = nil)
      guard_initial_state!(initial_state)

      @dispatcher = Dispatcher.new
      @state      = Zinke::Immutable.from_object(initial_state || {})
    end

    def dispatch(action)
      @dispatcher.dispatch(action)
    end

    def subscribe(action_type = nil, &block)
      definition = ->(action) { instance_exec(action, &block) }

      @dispatcher.subscribe(action_type, definition: definition)
    end

    def unsubscribe(listener)
      @dispatcher.unsubscribe(listener)
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
