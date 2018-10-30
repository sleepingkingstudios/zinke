# frozen_string_literal: true

require 'observer'

require 'zinke'
require 'zinke/listeners/base_listener'
require 'zinke/listeners/type_listener'

module Zinke
  # Helper class implementing Observable and building Listener instances when
  # subscribing to actions.
  class Dispatcher
    ITERATION_ERROR = "can't add a new key into hash during iteration"
    private_constant :ITERATION_ERROR

    # Error message to display when #update tries to add a listener.
    LISTENER_ERROR = "can't add a listener while dispatching an action"

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
    rescue RuntimeError => exception
      raise exception unless exception.message == ITERATION_ERROR

      raise LISTENER_ERROR
    end

    # Creates and adds an action listener. Any arguments and keywords are passed
    # to the #build_listener method along with the block. The resulting Listener
    # instance is added as an observer and then returned.
    #
    # To stop notifying the listener when a matching action is dispatched, pass
    # the returned listener to the #unsubscribe method.
    #
    # @overload subscribe
    #   @yieldparam action [Hash] The action object.
    #
    #   @return [Zinke::Listeners::BaseListener] the added listener.
    #
    # @overload subscribe(action_type:)
    #   @param action_type [String, Symbol] The type of action to listen for.
    #     The block will only be called for dispatched actions whose :type is
    #     equal to the expected action type.
    #
    #   @yieldparam action [Hash] The action object.
    #
    #   @return [Zinke::Listeners::TypeListener] the added listener.
    #
    # @see #dispatch
    #
    # @see #unsubscribe
    def subscribe(*args, **kwargs, &block)
      listener = build_listener(*args, **kwargs, &block)

      add_observer(listener)

      listener
    end

    # Removes a subscribed listener. The listener will no longer be notified
    # when a matching action is dispatched.
    #
    # @param listener [Zinke::Listeners::BaseListener] The listener to remove.
    #
    # @see #subscribe
    def unsubscribe(listener)
      delete_observer(listener)
    end

    private

    def build_listener(*_args, **kwargs, &block)
      if kwargs.key?(:action_type)
        return Zinke::Listeners::TypeListener
            .new(action_type: kwargs[:action_type], &block)
      end

      Zinke::Listeners::BaseListener.new(&block)
    end
  end
end
