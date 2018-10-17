# Zinke

The Zinke gem implements the Reducer pattern in Ruby, as seen in JavaScript libraries like React and languages like Elm. This provides a Store that serves as a single, stable source of truth for stateful applications.

It defines the following concepts:

- [Stores](#label-Stores) - Encapsulates a state and dispatches and subscribes to actions.
- [Reducers](#label-Reducers) - Mechanism for updating a state based on dispatched actions.

## About

[comment]: # "Status Badges will go here."

The Reducer pattern is better known in the front-end world, and underpins the Redux library for JavaScript applications and state management in Elm projects. By encapsulating the state in a store and using reducers to manage changes to the state, you decouple the state from its consumers. This provides several advantages:

- **Control:** You define when and how the state can change.
- **Consistency:** Well-defined states and transitions provide a consistent interface for consumers to dispatch and subscribe to updates.
- **Testability:** Unit test states and transitions without worrying about consumers, and test state consumers with their expected states and transitions without a complicated setup of the initial state.

See also:

- [Redux](https://redux.js.org/): A popular JavaScript library implementing the reducer pattern. The Redux documentation was heavily referenced while developing Zinke.
- [Elm](https://guide.elm-lang.org/): A functional language that compiles to JavaScript.

### Compatibility

Cuprum is tested against Ruby (MRI) 2.5.

### Documentation

Method and class documentation is available courtesy of [RubyDoc](http://www.rubydoc.info/github/sleepingkingstudios/zinke/master).

Documentation is generated using [YARD](https://yardoc.org/), and can be generated locally using the `yard` gem.

### License

Copyright (c) 2018 Rob Smith

Cuprum is released under the [MIT License](https://opensource.org/licenses/MIT).

### Contribute

The canonical repository for this gem is located at https://github.com/sleepingkingstudios/zinke.

To report a bug or submit a feature request, please use the [Issue Tracker](https://github.com/sleepingkingstudios/zinke/issues).

To contribute code, please fork the repository, make the desired updates, and then provide a [Pull Request](https://github.com/sleepingkingstudios/zinke/pulls). Pull requests must include appropriate tests for consideration, and all code must be properly formatted.

### Credits

Hi, I'm Rob Smith, a Ruby Engineer and the developer of this library. I use these tools every day, but they're not just written for me. If you find this project helpful in your own work, or if you have any questions, suggestions or critiques, please feel free to get in touch! I can be reached [on GitHub](https://github.com/sleepingkingstudios/cuprum) or [via email](mailto:merlin@sleepingkingstudios.com). I look forward to hearing from you!

## Concepts

### Stores

    require 'zinke/store'

Stores are the core feature of Zinke. Each store encapsulates a state and provides methods to dispatch and subscribe to updates to that state.

```ruby
require 'hamster'
require 'zinke/state'

class BankStore < Zinke::Store
  def balance(account_id)
    index = account_index(account_id)

    state.get(:accounts).get(index).get(:balance)
  end

  private

  def account_index(account_id)
    state.get(:accounts).find_index { |account| account[:id] == account_id }
  end
end

initial_state = {
  accounts: [
    {
      id: 0,
      balance: 500.0
    },
    {
      id: 1,
      balance: 1_500.0
    },
    {
      id: 2,
      balance: -25.0
    }
  ]
}
immutable_state = Hamster::Hash.new(initial_state)
bank_store      = BankStore.new(immutable_state)

bank_store.state
#=> Hamster::Hash[accounts: [{ id: 0, balance: 500.0 }, { ... }, { ... }]]
bank_store.balance(1)
#=> 1500.0
```

Notice that in this example we are using the Hamster gem to make our initial state immutable. Zinke does not have a dependency on Hamster or any specific immutability library, nor does it enforce that the state must be immutable. It is, however, very strongly recommended.

#### Initial State

If `Store.new` is called with nil or with no arguments, it will initialize the store with the default state, which is an empty hash. To override this behavior, redefine the private `#initial_state` method on your Store subclass.

```ruby
class BankStore < Zinke::Store
  private

  def initial_state
    Hamster::Hash[accounts: []]
  end
end

empty_store = BankStore.new
empty_store.state
#=> Hamster::Hash[accounts: []]
```

Even if an initial state is defined, passing a non-`nil` value will set the state of the store to the passed value.

#### Dispatching Actions

Updates to the state are handled using the `Store#dispatch` method, which takes a single argument. This argument is the action, which is traditionally a Hash with a `:type` key and optionally other keys and values representing additional data.

```ruby
# This action will deposit $50 into the account with id 0.
deposit_action = { type: :deposit, account_id: 0, balance: 50.0 }

# This action will withdraw $25 from the account with id 1.
withdrawal_action = { type: :withdraw, account_id: 0, balance: 25.0 }
```

Before we dispatch these actions, though, we need to subscribe to the `:deposit` and `:withdraw` events.

#### Subscribing to Actions

Now that we have our store set up, we need to keep an eye on it. `Zinke::Store` defines the `#subscribe` method for this purpose. Continuing our example above:

```ruby
class BankStore
  def initialize(initial_state)
    super

    # Whenever the store dispatches a :deposit action, we'll call the #deposit
    # method and set the state to the new value. The id of the account and the
    # amount to deposit are dispatched as part of the action.
    subscribe(:deposit) do |action|
      self.state = deposit(action[:account_id], action[:amount])
    end

    subscribe(:withdraw) do |action|
      self.state = withdraw(action[:account_id], action[:amount])
    end
  end

  private

  # Our deposit method does the arithmetic and returns a new state with the
  # updated balance of the appropriate account. Because we are using an
  # immutable state, there is no danger of accidentally changing the previous # state or any references to it.
  def deposit(id, amount)
    index   = account_index(id)
    balance = state.get(:accounts).get(index).get(:balance)

    state.put_at(:accounts, index, :balance) { balance + amount }
  end

  def withdraw(account_id, amount)
    index   = account_index(id)
    balance = state.get(:accounts).get(index).get(:balance)

    state.put_at(:accounts, index, :balance) { balance - amount }
  end
end

audit_log = []

# We want to keep track of all changes to the accounts, so we use the
# #subscribe method with no action name. All dispatched actions will be added
# to our audit log, regardless of the action name.
bank_store.subscribe do |action|
  audit_log << action
end

bank_store.dispatch(deposit_action)
bank_store.state
#=> Hamster::Hash[accounts: [{ id: 0, balance: 550.0 }, { ... }, { ... }]]
bank_store.balance(0)
#=> 550.0

bank_store.dispatch(withdrawal_action)
bank_store.balance(1)
#=> 1475.0

audit_log
#=> [
#     { type: :deposit, account_id: 0, balance: 50.0 },
#     { type: :withdraw, account_id: 0, balance: 25.0 }
#   ]
```

This logic can be better handled with Reducers (see below), but the underlying implementation is based on the `Store#subscribe` method.

#### Unsubscribing From Actions

You can unsubscribe from actions by storing a reference to the listener object.

```ruby
def watch_for_fraud(action)
  raise 'withdrawal too large' if action[:amount] > 25.0
end

listener =
  bank_store.subscribe(:withdraw) do |action|
    watch_for_fraud(action)
  end

# Sometime later...
bank_store.unsubscribe(listener)

# Does not raise the error.
bank_store.dispatch(type: :withdraw, account_id: 0, amount: 50.0)
```

### Reducers

It's possible to model state changes using `Store#dispatch` and `#subscribe`, but adding a Reducer provides a simpler mechanism for handling changes to the state, in addition to the benefits of better-organized code.

To define a reducer, create a Module and `include Zinke::Reducer`. Then to use your new reducer, just `include` it in your Store class.

Let's revisit our sample application and define a reducer for it.

```ruby
module BankReducer
  include Zinke::Reducer

  update :deposit, :handle_deposit

  update :withdraw, :handle_withdrawal

  update :transfer do |state, action|
    state = handle_deposit(
      state,
      {
        account_id: action[:to_account_id],
        amount: action[:amount]
      }
    )

    handle_withdrawal(
      state,
      {
        account_id: action[:from_account_id],
        amount: action[:amount]
      }
    )
  end

  private

  def handle_deposit(state, action)
    account, index = find_account_with_index(action[:account_id])
    new_balance    = account.get(:balance) + action[:amount]

    state.put_at(:accounts, index, :balance) { new_balance }
  end

  def handle_withdrawal(state, action)
    account, index = find_account_with_index(action[:account_id])
    new_balance    = account.get(:balance) - action[:amount]

    raise 'insufficient funds' if new_balance < 0

    state.put_at(:accounts, index, :balance) { new_balance }
  end
end

class BankStoreWithReducers < Zinke::Store
  include BankReducer
end
```

All of our business logic has been refactored from the store to our new reducer. The `::update` class method in our reducer takes the place of manually `#subscribe`-ing to actions, and also handles updating the state. Each update just returns the new state, and the reducer handles the rest automatically.

Because we are using pure reducers with no side effects (see below) and an immutable state object, we're protected from some possible errors in our business logic. For example, in our `:transfer` update, we are depositing the amount before the "insufficient funds" error is raised - but since `:transfer` will not return a state, that change is never reflected in the Store. In effect, raising an error results in a free rollback of any changes in a pure reducer.

Each Store can include multiple reducers. If more than one reducer handles a particular action type, then each update will be called in sequence with the state returned by the previous update (and, of course, the action).

#### Pure Reducers

Let's take a closer look at what a pure reducer is. In a nutshell, in a pure reducer each `::update` handler must be a pure function with no side effects. A pure function always has the same behavior given the same inputs, does not mutate the inputs, and does not read from or write to anything outside of the function.

That means the update cannot:

- Access the file system (read or write files).
- Access a data store (such as a SQL database or MongoDB document store).
- Access external services (including logging or system instrumentation).
- Call any methods that are not also pure functions (for example, Time.new is not a pure function, because it does not always return the same value with the same inputs).

For logging and instrumentation, use the `Store#subscribe` method. For accessing other systems or services, that should be handled by the code that is dispatching actions. In other words, treat your store as a composed object that is used by your application code, rather than embedding external references in your store or reducer.

### Actions

In our above examples, we used symbols to define our actions. This is fine for a small application, but as a project grows it can lead to issues, especially as more concepts are added to the domain. If two different parts of your application try and use a `:query` action for two different things, you have some debugging ahead of you.

There is also the problem of typos. What happens when you dispatch a `:deposlt` action? Nothing, because your reducer is looking for `:deposit`. A similar issue arises if an action name changes.

Thus, the recommendation is to use scoped strings - for example, 'users.balance.query' and 'admin.transactions.query'. To resolve the issue of changes or typos, use constant values. For example, in our bank application:

```ruby
# frozen_string_literal: true

module BankActions
  DEPOSIT  = 'bank.deposit'
  WITHDRAW = 'bank.withdraw'
  TRANSFER = 'bank.transfer'
end
```

Thus, our reducer would look like this:

```ruby
module BankReducerWithActions
  update BankActions::DEPOSIT, :handle_deposit
end

bank_store.dispatch(type: BankActions::DEPOSIT, account_id: 1, amount: 50.0)
```

#### Action Creators

Taking things one step further, we can add a function to build our actions.

```ruby
# frozen_string_literal: true

module BankActions
  DEPOSIT = 'bank.deposit'

  def self.deposit(id:, amount:)
    {
      type:       DEPOSIT,
      account_id: id,
      amount:     amount
    }
  end
end

bank_store.dispatch(BankActions.deposit(id: 1, amount: 50.0))
```
