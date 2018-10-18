# frozen_string_literal: true

require 'zinke'

module Zinke
  # Provides a mechanism for updating the state of a store based on dispatched
  # actions. Include Zinke::Reducer into a custom reducer module, and then
  # include the reducer in your Store class.
  module Reducer
    # Class methods to include in a custom reducer module.
    module ClassMethods
      # Defines a reducer for any stores in which the module is included. Will
      # be automatically subscribed when the store is initialized.
      #
      # When an action is dispatched, each matching reducer is called in the
      # order they were defined (or if multiple Zinke::Reducers are included) in
      # the store, in the order the modules were included. Each reducer is
      # called with the current state of the store and the dispatched action,
      # and will set the store state to the value returned by the reducer.
      #
      # If there are multiple matching reducers, then each subsequent reducer
      # will be called with the state returned by the previous reducer.
      #
      # @param action_name [String, Symbol] The type of action to listen
      #   for. The reducer will only be called for dispatched actions of the
      #   specified type.
      #
      # @overload update(action_name, method_name)
      #   @param method_name [String, Symbol] The name of the method to call
      #     when a matching action is dispatched. The method must accept two
      #     parameters - the current state and the dispatched action - and must
      #     return the new state.
      #
      # @overload update(action_name)
      #   @yieldparam state [Object] The current state.
      #   @yieldparam action [Hash] The dispatched action.
      #   @yieldreturn [Object] The new state.
      def update(action_name, method_name = nil, &block)
        block ||= ->(state, action) { send(method_name, state, action) }

        updates << [action_name, block]
      end

      private

      def updates
        @updates ||= []
      end
    end

    # @api private
    def self.included(mod)
      super

      mod.extend(ClassMethods)
    end

    # When included in a store, will subscribe each reducer (defined using
    # Zinke::Reducer.update) when the store is initialized.
    def initialize(*args, &block)
      super

      initialize_reducers
    end

    private

    def initialize_reducers
      reducers.each do |(action_name, block)|
        subscribe(action_type: action_name) do |action|
          self.state = instance_exec(state, action, &block)
        end
      end
    end

    def reducers
      self
        .class
        .ancestors
        .inject([]) do |ary, ancestor|
          next ary unless ancestor < Zinke::Reducer
          next ary unless ancestor.respond_to?(:updates, true)

          ary + ancestor.send(:updates)
        end
    end
  end
end
