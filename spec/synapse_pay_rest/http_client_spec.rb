require "spec_helper"

RSpec.describe SynapsePayRest::HTTPClient do
  let(:client_id) { "e3f19e4bd4022c86e7f2" }
  let(:client_secret) { "11c94ba6bad74d24a0158bc707f0fc19a86dc08f" }
  let(:ip_address) { "107.170.246.225" }
  let(:fingerprint) { "e716990e50b67a1177736960b6357524b22090ccab093d068b3d7a18dbde3f4c" }

  let(:url_base) { "https://sandbox.synapsepay.com/api/3" }
  let(:params) do
    {
      "fingerprint" => fingerprint,
      "client_id" => client_id,
      "client_secret" => client_secret,
      "ip_address" => ip_address,
    }
  end
  let(:client) { SynapsePayRest::HTTPClient.new(params, url_base) }

  # describe "#post" do
  #   it_calls_correct_rest_method :post, payload: {}
  # end
  #
  # describe "#patch" do
  #   it_calls_correct_rest_method :patch, payload: {}
  # end

  describe "#get" do
    let(:result) do
      result = client.get(path)
      p result
      result
    end

    # Basic error handling is tested through get requests all of the
    # http methods use the same error handling mechanism.
    context "when there are errors" do
      context "when url is invalid" do
        let(:path) { "/users/xyz" }
        it "handles without crashing" do
          expect(result["error_code"]).to eq("404")
          expect(result["error"]["en"]).to be_a(String)
          expect(result["success"]).to eq(false)
        end
      end
    end

    context "happy path", :vcr do
      let(:path) { "/users" }
      it "handles without crashing" do
        expect(result["error_code"]).to eq("0")
        expect(result["success"]).to eq(true)
      end
    end
  end

  # describe "#delete" do
  #   it_calls_correct_rest_method :delete
  # end
end
