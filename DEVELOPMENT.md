# Development

## Version 0.1.0

- remove hamster dev dependency
  - remove Zinke::Immutable
  - using an immutable state is Strongly Recommended, but you do you

### Documentation

- README
- method documentation

## Future Versions

### Actions

- DSL for defining actions, action creators:

  ```
  module Magic::Actions
    include Zinke::Actions

    action :cast, :spell
  end

  Magic::Actions::CAST #=> 'magic.actions.cast'
  Magic::Actions.cast('magic missile', target: 'goblin')
  #=> { type: 'magic.actions.cast', spell: 'magic missile', target: 'goblin' }
  ```

### Listeners

- extract Dispatcher, Listener
- Listener subclasses
  - base - no filtering                          #=> Listener
  - action_type exact match (current Listener)   #=> TypeListener
  - action_type included in set                  #=> TypeSetListener
  - action_type matches matchable (RegExp, proc) #=> MatchListener
- Store#subscribe overloads:
  - subscribe(listener)
  - subscribe { |action| }
  - subscribe(action_name) { |action| }
  - subscribe(\*action_names) { |action| }
    #=> Set.new(action_names).include?(action[:type])
  - subscribe(pattern) { |action| }
    #=> pattern === action[:type]
  - subscribe(proc) { |action| }
    #=> proc === action[:type]

### Store

- #initial_state
