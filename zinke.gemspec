# frozen_string_literal: true

$LOAD_PATH << './lib'

require 'zinke/version'

Gem::Specification.new do |gem|
  gem.name = 'zinke'
  gem.version = Zinke::VERSION
  gem.date = Time.now.utc.strftime '%Y-%m-%d'
  gem.summary = 'An implementation of the Reducer pattern in Ruby.'

  description = <<~DESCRIPTION
    The zinke gem implements the Reducer pattern in Ruby, as seen in JavaScript
    libraries like React and languages like Elm. This provides a Store that
    serves as a single, stable source of truth for stateful applications.
  DESCRIPTION

  gem.description = description.strip.gsub(/\n +/, ' ')
  gem.authors = ['Rob "Merlin" Smith']
  gem.email = ['merlin@sleepingkingstudios.com']
  gem.homepage = 'http://sleepingkingstudios.com'
  gem.license = 'MIT'

  gem.require_path = 'lib'
  gem.files = Dir['lib/**/*.rb', 'LICENSE', '*.md']

  gem.add_development_dependency 'rspec', '~> 3.8'
  gem.add_development_dependency 'rspec-sleeping_king_studios', '2.4.0'
  gem.add_development_dependency 'rubocop', '~> 0.59', '>= 0.59.2', '< 0.60'
  gem.add_development_dependency 'rubocop-rspec', '~> 1.30.0', '< 1.31'
  gem.add_development_dependency 'simplecov', '~> 0.16', '>= 0.16.1'
  gem.add_development_dependency 'sleeping_king_studios-tasks', '~> 0.1'
  gem.add_development_dependency 'thor', '~> 0.20'
end
