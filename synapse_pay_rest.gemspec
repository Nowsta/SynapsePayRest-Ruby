# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'synapse_pay_rest/version'

Gem::Specification.new do |spec|
  spec.name        = 'synapse_pay_rest'
  spec.version     = SynapsePayRest::VERSION
  spec.authors     = ["Thomas Hipps", "Nowsta Team"]
  spec.email       = 'eric@nowsta.com'

  spec.summary     = "SynapsePay v3 Rest API Wrapper"
  spec.description = "A simple ruby wrapper for the SynapsePay v3 Rest API"
  spec.homepage    = 'https://github.com/Nowsta/SynapsePayRest-Ruby'
  spec.license     = 'MIT'

  spec.require_paths = ["lib"]
  spec.files       = Dir.glob("{lib}/**/*")

  spec.add_dependency "rest-client", "~> 2.0"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 1.20"
  spec.add_development_dependency "vcr", "~> 3.0"
end
