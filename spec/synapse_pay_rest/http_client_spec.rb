require 'rest-client'

require_relative '../../lib/synapse_pay_rest/http_client.rb'

RSpec.describe do
  let(:client) { SynapsePayRest::HTTPClient.new({}, '') }

  def self.it_calls_correct_rest_method(method, payload: nil)
    it "calls the correct rest client method" do
      allow(RestClient::Request).to receive(:execute).and_return('{}')
      args = ['']
      args << payload if payload
      client.method(method).call(*args)
      expect(RestClient::Request).to have_received(:execute).
        with(hash_including(method: method))
    end
  end

  describe "#post" do
    it_calls_correct_rest_method :post, payload: {}
  end

  describe "#patch" do
    it_calls_correct_rest_method :patch, payload: {}
  end

  describe "#get" do
    it_calls_correct_rest_method :get
  end

  describe "#delete" do
    it_calls_correct_rest_method :delete
  end
end
