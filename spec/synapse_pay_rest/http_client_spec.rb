require "spec_helper"

RSpec.describe SynapsePayRest::HTTPClient do
  let(:client_id) { "e3f19e4bd4022c86e7f2" }
  let(:client_secret) { "11c94ba6bad74d24a0158bc707f0fc19a86dc08f" }
  let(:ip_address) { "107.170.246.225" }
  let(:fingerprint) { "e716990e50b67a1177736960b6357524b22090ccab093d068b3d7a18dbde3f4c" }

  let(:url_base) { "https://sandbox.synapsepay.com/api/3" }
  let(:path) { "/users" }
  let(:base_params) do
    {
      "fingerprint" => fingerprint,
      "client_id" => client_id,
      "client_secret" => client_secret,
      "ip_address" => ip_address,
    }
  end
  let(:params) { base_params }
  let(:client) { SynapsePayRest::HTTPClient.new(params, url_base) }

  describe "#get" do
    let(:result) { client.get(path) }

    # Basic error handling is tested through get requests.
    # All http methods use the same error handling mechanism so when possible
    # it is best to try to keep most of the error handling code in this
    # context.
    context "when there are errors" do
      context "when the synapse response is a well formed error", :vcr do
        let(:path) { "/users/xyz" }

        it { expect(result["http_code"]).to eq("404") }
        it { expect(result["error_code"]).to eq("404") }
        it { expect(result["error"]["en"]).to be_a(String) }
        it { expect(result["success"]).to eq(false) }
      end

      context "when the synapse response is not a well formed error" do
        before(:each) do
          # error result of a 5XX error producing html pulled from bugsnag
          # https://bugsnag.com/nowsta-1/pay/errors/576c0020e8a4560f523354b3
          body = '<html><head><title>504 Gateway Time-out</title></head>' \
            '<body><h1>504 Gateway Time-out</h1></body></html>'
          stub_request(:any, /#{url_base}/).to_return(body: body, status: 504)
        end

        it { expect(result["http_code"]).to eq("504") }
        it { expect(result["error_code"]).to eq("500") }
        it { expect(result["error"]["en"]).to be_a(String) }
        it { expect(result["success"]).to eq(false) }
      end

      context "when client timeout is reached" do
        before(:each) do
          msg = "Timed out connecting to server."
          allow(RestClient::Request).to receive(:execute).with(
            hash_including(timeout: timeout)
          ).and_raise(RestClient::Exceptions::ReadTimeout.new(msg))
        end
        let(:timeout) { 0.4 }
        let(:params) { base_params.merge("timeout" => timeout) }

        it { expect(result["http_code"]).to eq("504") }
        it { expect(result["error_code"]).to eq("500") }
        it { expect(result["error"]["en"]).to be_a(String) }
        it { expect(result["success"]).to eq(false) }
      end
    end

    context "happy path", :vcr do
      it { expect(result["error_code"]).to eq("0") }
      it { expect(result["success"]).to eq(true) }
    end
  end

  # since all the error testing id done by the get request, we just need
  # to check that the rest client is getting called with the correct inputs.
  def self.it_makes_request_with_body(method:)
    it "makes request with with body" do
      response = { "expected" => "response" }
      allow(RestClient::Request).to receive(:execute).and_return(response.to_json)

      payload = { "expected" => "payload" }
      expect(client.send(method, path, payload)).to eq(response)
      expect(RestClient::Request).to have_received(:execute).with(
        hash_including(method: method, url: url_base + path, payload: payload.to_json)
      )
    end
  end

  describe "#post" do
    it_makes_request_with_body method: :post
  end

  describe "#patch" do
    it_makes_request_with_body method: :patch
  end

  describe "#delete" do
    it "makes delete request" do
      response = { "expected" => "response" }
      allow(RestClient::Request).to receive(:execute).and_return(response.to_json)

      expect(client.delete(path)).to eq(response)
      expect(RestClient::Request).to have_received(:execute).with(
        hash_including(method: :delete, url: url_base + path)
      )
    end
  end
end
