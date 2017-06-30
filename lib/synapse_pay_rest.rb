require "synapse_pay_rest/version"

# Basic wrapper around the the requests library.
require_relative "synapse_pay_rest/http_client"
# Assign all the api classes
require_relative "synapse_pay_rest/api/Users"
require_relative "synapse_pay_rest/api/Nodes"
require_relative "synapse_pay_rest/api/Trans"

module SynapsePayRest
  class Client

    attr_accessor :client
    attr_accessor :users
    attr_accessor :nodes
    attr_accessor :trans

    def initialize(options: raise("options is required"), user_id: nil)
      base_url = 'https://api.synapsefi.com/v3.1'
      if options.has_key?('development_mode')
        if options['development_mode']
          base_url = 'https://uat-api.synapsefi.com/v3.1'
        end
      end

      @client = HTTPClient.new options, base_url, user_id: user_id
      @users = Users.new @client
      @nodes = Nodes.new @client
      @trans = Trans.new @client
    end
  end
end
