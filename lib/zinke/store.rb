# frozen_string_literal: true

require 'observer'

module Zinke
  # Encapsulates a single state and provides dispatch and subscribe methods to
  # notify on updates to that state.
  class Store
    # Helper class implementing Observable and providing a less cryptic error
    # message when adding a listener while dispatching an action.
    class Dispatcher
      include Observable

      # Dispatches an action. All subscribed listeners will be notified via
      # their respective #update methods, which will be called with the action
      # as a parameter.
      #
      # @param action [Hash] The action object. By convention, should be a Hash
      #   with a :type key and a String or Symbol value, and can have other keys
      #   and values representing additional data.
      #
      # @raise RuntimeError if any of the subscribed listeners calls #subscribe.
      #
      # @see #subscribe
      def dispatch(action)
        changed

        notify_observers(action)
      end

      # Creates and adds an action listener with the specified definition and
      # action type (if any). When an event is dispatched, each subscribed
      # listener will have its #update method called with the action as a
      # parameter.
      #
      # @param action_type [String, Symbol, nil] The type of action to listen
      #   for. The definition will only be called for dispatched actions of the
      #   specified type. If no action type is given, the definition will be
      #   called for all dispatched actions. Defaults to nil.
      #
      # @param definition [Proc, #call] An executable object, called by the
      #   #update method of the listener when a matching action is dispatched.
      #   Must define the #call method with one argument, which will be the
      #   dispatched action.
      #
      # @return [Zinke::Store::Listener] The added listener. To stop notifying
      #   the listener when a matching action is dispatched, pass this to the
      #   #unsubscribe method.
      #
      # @see #dispatch
      #
      # @see #unsubscribe
      def subscribe(action_type = nil, definition:)
        listener = Listener.new(action_type, definition: definition)

        add_observer(listener)

        listener
      end

      # Removes a subscribed listener. The listener will no longer be notified
      # when a matching action is dispatched.
      #
      # @param listener [Zinke::Store::Listener] The listener to remove.
      #
      # @see #dispatch
      def unsubscribe(listener)
        delete_observer(listener)
      end
    end

    # Helper class encapsulating an action handler. Optionally provides basic
    # equality check against an expected action type.
    #
    # @see Zinke::Store::Dispatcher#subscribe
    class Listener
      ITERATION_ERROR = "can't add a new key into hash during iteration"
      private_constant :ITERATION_ERROR

      # Error message to display when #update tries to add a listener.
      LISTENER_ERROR = "can't add a listener while dispatching an action"

      # @param action_type [String, Symbol, nil] The type of action to listen
      #   for. The definition will only be called for dispatched actions of the
      #   specified type. If no action type is given, the definition will be
      #   called for all dispatched actions. Defaults to nil.
      #
      # @param definition [Proc, #call] An executable object, called by the
      #   #update method when a matching action is dispatched. Must define the
      #   #call method with one argument, which will be the dispatched action.
      def initialize(action_type = nil, definition:)
        @action_type = action_type
        @definition  = definition
      end

      # Checks the type of the action and, if matching the expected action type,
      # calls the definition with the action.
      #
      # @param action [Hash] The action object. By convention, should be a Hash
      #   with a :type key and a String or Symbol value, and can have other keys
      #   and values representing additional data.
      #
      # @return [Object] The value returned by calling the definition.
      #
      # @raise RuntimeError if the definition tries to add another listener.
      #
      # @see Zinke::Store::Dispatcher#dispatch
      #
      # @see LISTENER_ERROR
      def update(action)
        return unless @action_type.nil? || @action_type == action[:type]

        @definition.call(action)
      rescue RuntimeError => exception
        raise unless exception.message == ITERATION_ERROR

        raise LISTENER_ERROR
      end
    end

    # @param initial_state [Hash, nil] The initial state of the store. Using an
    #   immutable data store is strongly recommended. Defaults to an empty hash.
    #
    # @raise ArgumentError if the initial state is not a Hash or nil.
    def initialize(initial_state = nil)
      @dispatcher = Dispatcher.new
      @state      = initial_state || {}
    end

    # @return [Object] the current state of the store.
    attr_reader :state

    # (see Zinke::Store::Dispatcher#dispatch)
    def dispatch(action)
      @dispatcher.dispatch(action)
    end

    # Creates and adds an action listener with the specified definition and
    # action type (if any). When an event is dispatched, each subscribed
    # listener will have its #update method called with the action as a
    # parameter.
    #
    # @param action_type [String, Symbol, nil] The type of action to listen
    #   for. The listener will only be called for dispatched actions of the
    #   specified type. If no action type is given, the listener will be
    #   called for all dispatched actions. Defaults to nil.
    #
    # @yieldparam action [Hash] The dispatched action object. By convention,
    #   should be a Hash with a :type key and a String or Symbol value, and can
    #   have other keys and values representing additional data.
    #
    # @return [Zinke::Store::Listener] The added listener. To stop notifying
    #   the listener when a matching action is dispatched, pass this to the
    #   #unsubscribe method.
    #
    # @see #dispatch
    #
    # @see #unsubscribe
    def subscribe(action_type = nil, &block)
      @dispatcher.subscribe(action_type, definition: block)
    end

    # (see Zinke::Store::Dispatcher#unsubscribe)
    def unsubscribe(listener)
      @dispatcher.unsubscribe(listener)
    end

    protected

    attr_writer :state
  end
end
