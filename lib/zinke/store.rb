# frozen_string_literal: true

require 'forwardable'

require 'zinke/dispatcher'

module Zinke
  # Encapsulates a single state and provides dispatch and subscribe methods to
  # notify on updates to that state.
  class Store
    extend Forwardable

    # @param state [Hash, nil] The initial state of the store. Using an
    #   immutable data store is strongly recommended. Defaults to the value of
    #   #initial_state, which is an empty hash unless redefined by a subclass.
    #
    # @raise ArgumentError if the initial state is not a Hash or nil.
    def initialize(state = nil)
      @dispatcher = Zinke::Dispatcher.new
      @state      = state || initial_state
    end

    def_delegators :@dispatcher,
      :dispatch,
      :subscribe,
      :unsubscribe

    # @return [Object] the current state of the store.
    attr_reader :state

    protected

    attr_writer :state

    private

    attr_reader :dispatcher

    def initial_state
      {}
    end
  end
end
