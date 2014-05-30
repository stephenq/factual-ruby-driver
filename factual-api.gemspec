# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require lib + '/factual/api'

Gem::Specification.new do |s|
  s.name        = "factual-api"
  s.version     =  Factual::API::VERSION
  s.platform    = Gem::Platform::RUBY
  s.licenses    = ["Apache-2.0"]
  s.authors     = ["Rudiger Lippert", "Forrest Cao"]
  s.email       = ["rudy@factual.com", "forrest@factual.com"]
  s.homepage    = "http://github.com/Factual/factual-ruby-driver"
  s.summary     = "Ruby driver for Factual"
  s.description = "Factual's official Ruby driver for the Factual public API."

  s.required_ruby_version = '>= 1.8.6'
  s.required_rubygems_version = ">= 1.3.6"
  s.add_runtime_dependency("oauth", '~> 0.4.4', '>=0.4.4')
  s.add_runtime_dependency("json", '~> 1.2', '>=1.2.0')
  s.add_development_dependency "rspec", "~> 0"

  s.files        = Dir["lib/**/*.rb"] + %w(README.md CHANGELOG.md)
  s.executables  = []
  s.require_path = 'lib'
end
