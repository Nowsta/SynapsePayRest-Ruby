require "spec_helper"

RSpec.describe SynapsePayRest::HTTPClient do
  let(:client_id) { "e3f19e4bd4022c86e7f2" }
  let(:client_secret) { "11c94ba6bad74d24a0158bc707f0fc19a86dc08f" }
  let(:ip_address) { "107.170.246.225" }
  let(:fingerprint) { "e716990e50b67a1177736960b6357524b22090ccab093d068b3d7a18dbde3f4c" }

  let(:url_base) { "https://sandbox.synapsepay.com/api/3" }
  let(:path) { "" }
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
          stub_request(:any, url_base).to_return(body: body, status: 504)
        end

        it { expect(result["http_code"]).to eq("504") }
        it { expect(result["error_code"]).to eq("500") }
        it { expect(result["error"]["en"]).to be_a(String) }
        it { expect(result["success"]).to eq(false) }
      end

      context "when client timeout is reached" do
        before(:each) do
          msg = "Timed out connecting to server."
          allow(RestClient::Request).
            to receive(:execute).
            with(hash_including(timeout: timeout)).
            and_raise(RestClient::Exceptions::ReadTimeout.new(msg))
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
      let(:path) { "/users" }

      it { expect(result["error_code"]).to eq("0") }
      it { expect(result["success"]).to eq(true) }
    end
  end

  # describe "#delete" do
  #   it_calls_correct_rest_method :delete
  # end
  #
  # describe "#post" do
  #   it_calls_correct_rest_method :post, payload: {}
  # end
  #
  # describe "#patch" do
  #   it_calls_correct_rest_method :patch, payload: {}
  # end
end
