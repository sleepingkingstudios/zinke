# frozen_string_literal: true

require 'rspec/sleeping_king_studios/all'

# Isolated namespace for defining spec-only or transient objects.
module Spec; end

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.extend  RSpec::SleepingKingStudios::Concerns::ExampleConstants
  config.extend  RSpec::SleepingKingStudios::Concerns::FocusExamples
  config.extend  RSpec::SleepingKingStudios::Concerns::WrapExamples
  config.include RSpec::SleepingKingStudios::Examples::PropertyExamples

  # rspec-expectations config goes here.
  config.expect_with :rspec do |expectations|
    # Enable only the newer, non-monkey-patching expect syntax.
    expectations.syntax = :expect

    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here.
  config.mock_with :rspec do |mocks|
    # Enable only the newer, non-monkey-patching expect syntax.
    mocks.syntax = :expect

    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended.
    mocks.verify_partial_doubles = true
  end

  config.disable_monkey_patching!

  # Allows RSpec to persist some state between runs.
  config.example_status_persistence_file_path = 'spec/examples.txt'

  # This allows you to limit a spec run to individual examples or groups
  # you care about by tagging them with `:focus` metadata.
  config.filter_run_when_matching :focus

  # Run specs in random order to surface order dependencies.
  config.order = :random
  Kernel.srand config.seed

  # Print the 10 slowest examples and example groups.
  config.profile_examples = 10 if ENV['CI']

  config.shared_context_metadata_behavior = :apply_to_host_groups

  # This setting enables warnings.
  config.warnings = false
end
