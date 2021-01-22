RSpec.describe("v1 redirects") do
  include ::Spec::Support::TenantIdentity
  include ::V1x0Helper

  let(:headers)          { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }

  describe("v1.0") do
    it "preserves the openapi.json file extension when not using a redirect" do
      get("#{api_version}/openapi.json")
      expect(response.status).to eq(200)
      expect(response.headers["Location"]).to be_nil
    end

    it "direct request doesn't break service_instances" do
      get("#{api_version}/service_instances", :headers => headers)
      expect(response.status).to eq(200)
      expect(response.headers["Location"]).to be_nil
    end
  end
end
