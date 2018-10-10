# frozen_string_literal: true

require 'zinke'

module Zinke
  # Provides a mechanism for updating the state of a store based on dispatched
  # actions. Include Zinke::Reducer into a custom reducer module, and then
  # include the reducer in your Store class.
  module Reducer
    # Class methods to include in a custom reducer module.
    module ClassMethods
      def update(action_name, method_name = nil, &block)
        block ||= ->(state, action) { send(method_name, state, action) }

        updates << [action_name, block]
      end

      private

      def updates
        @updates ||= []
      end
    end

    def self.included(mod)
      super

      mod.extend(ClassMethods)
    end

    def initialize(*args, &block)
      super

      initialize_reducers
    end

    private

    def initialize_reducers
      reducers.each do |(action_name, block)|
        subscribe(action_name) do |action|
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
