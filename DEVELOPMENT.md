# Development

## Version 0.1.0

## Version 0.2.0

### Actions

- DSL for defining actions, action creators:

  ```
  module Magic::Actions
    include Zinke::ActionCreator

    action :cast, :spell
  end

  Magic::Actions::CAST #=> 'magic.actions.cast'
  Magic::Actions.cast('magic missile', target: 'goblin')
  #=> { type: 'magic.actions.cast', spell: 'magic missile', target: 'goblin' }
  ```

### Listeners

- extract Dispatcher, Listener
- Listener subclasses
  - base - no filtering                          #=> Listeners::Base
  - action_type exact match (current Listener)   #=> Listeners::TypeListener

### Stores

- #initial_state

## Future Versions

### Actions

- ActionCreator block form? :
  ```
  action :action_name do
    argument :arg_1
    argument :arg_2, required: false
    arguments :rest

    keyword :key_1,
    keyword :key_2, required: true
    keywords :options
  end
  ```

### Listeners

- Listener subclasses
  - action_type included in set                  #=> TypeSetListener
  - action_type matches matchable (RegExp, proc) #=> MatchListener
- ListenerFactory:
  - build(listener)
  - build { |action| }
  - build(action_name) { |action| }
  - build(\*action_names) { |action| }
    #=> Set.new(action_names).include?(action[:type])
  - build(pattern) { |action| }
    #=> pattern === action[:type]
  - build(proc) { |action| }
    #=> proc === action[:type]

### Store

- inject dispatcher in constructor
- inject listener_factory in constructor
  - #subscribe delegates to @listener_factory
