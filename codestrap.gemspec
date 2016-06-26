# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'codestrap/version'

Gem::Specification.new do |spec|
  spec.name          = 'codestrap'
  spec.version       = Codestrap::VERSION
  spec.authors       = ['Dexter Plameras']
  spec.email         = ['dpgrps@gmail.com']
  spec.summary       = %q{File codestrap and boilerplate command line tool.}
  spec.description   = <<EOF
Codestrap is a file codestrap and boilerplate project tool. It is run from the command line
and has been designed to make use of the CLIs autocomplete functionality available
on supported operating systems shells.
EOF
  spec.homepage      = ''
  spec.license       = 'Apache'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'sinatra', '~> 1.4.5'
  spec.add_runtime_dependency 'ptools'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'cucumber'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'shotgun'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'redcarpet'
  spec.add_development_dependency 'mocha'
end
