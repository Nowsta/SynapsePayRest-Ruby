$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "synapse_pay_rest"
require "webmock/rspec"
require "vcr"

RSpec.configure do |c|
  c.disable_monkey_patching!
  c.color = true
end

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.allow_http_connections_when_no_cassette = false
end
