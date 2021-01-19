describe Api::V1x0::Mixins::ShowMixin do
  describe Api::V1x0::SourcesController, :type => :request do
    include ::Spec::Support::TenantIdentity

    let(:headers)     { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
    let!(:source_1)   { Source.create!(:tenant => tenant, :uid => SecureRandom.uuid) }
    let!(:source_2)   { Source.create!(:tenant => tenant, :uid => SecureRandom.uuid) }

    it "Primary Collection: get /sources lists all Sources" do
      get(api_v1x0_source_url(source_1.id), :headers => headers)

      expect(response.status).to eq(200)
      expect(response.parsed_body).to include("id" => source_1.id.to_s, "uid" => source_1.uid)
    end
  end
end
