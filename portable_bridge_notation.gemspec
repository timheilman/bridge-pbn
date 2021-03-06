# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'portable_bridge_notation/version'

Gem::Specification.new do |spec|
  spec.name          = 'portable_bridge_notation'
  spec.version       = PortableBridgeNotation::VERSION
  spec.authors       = ['Tim Heilman', 'Daniel Evans']
  spec.email         = ['tim@dv8.org', 'evans.daniel.n@gmail.com']

  spec.summary       = 'Pure Ruby Portable Bridge Notation (PBN) utilities for Contract Bridge card game data'
  spec.homepage      = 'https://github.com/timheilman/bridge-pbn'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.5', '>= 3.5.0'

  spec.add_runtime_dependency 'activesupport-inflector', '~> 0'
  spec.add_runtime_dependency 'i18n', '~> 0.6.6' # should be a dependency of the activesupport-inflector, but isn't
end
