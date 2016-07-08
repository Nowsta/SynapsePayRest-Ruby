lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name        = 'synapse_pay_rest'
  s.version     = '0.0.11'
  s.date        = %q{2016-07-08}
  s.summary     = "SynapsePay v3 Rest API Wrapper"
  s.description = "A simple ruby wrapper for the SynapsePay v3 Rest API"
  s.authors     = ["Thomas Hipps", "Nowsta Team"]
  s.email       = 'eric@nowsta.com'
  s.require_paths = ["lib"]
  s.files       = Dir.glob("{lib}/**/*")
  s.homepage    = 'https://github.com/Nowsta/SynapsePayRest-Ruby'
  s.license     = 'MIT'
  s.add_dependency "rest-client"
end
