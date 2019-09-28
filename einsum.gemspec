# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'einsum/version'

Gem::Specification.new do |spec|
  spec.name          = 'einsum'
  spec.version       = Einsum::VERSION
  spec.authors       = ['Todd Sundsted']
  spec.email         = ['todd@sumall.com']

  spec.summary       = 'Unoptimized, pure-Ruby implementation of a subset of Numpy `einsum`.'
  spec.homepage      = 'https://github.com/toddsundsted/einsum'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'byebug', '~> 10.0'
  spec.add_development_dependency 'pry', '~> 0.12'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'rubocop', '~> 0.63'
  spec.add_development_dependency 'sorbet', '~> 0'
  spec.add_development_dependency 'sorbet-runtime', '~> 0'
end
