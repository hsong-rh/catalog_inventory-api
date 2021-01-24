describe SourceCreateTaskService do
  let(:subject) { described_class.new(params) }

  before do
    allow(ClowderConfig).to receive(:instance).and_return({"SOURCE_TYPE_ID" => 10})
  end

  around do |example|
    Insights::API::Common::Request.with_request(default_request) do |request|
      tenant = Tenant.find_or_create_by(:external_tenant => request.tenant)
      ActsAsTenant.with_tenant(tenant) { example.call }
    end
  end

  describe "#process" do
    context "when source_type_id matches the environment" do
      let(:params) { {'id' => 200, 'source_type_id' => 10, 'uid' => SecureRandom.uuid, 'name' => 'xyz'} }

      it "should create a Source" do
        subject.process

        expect(Source.count).to eq(1)
        expect(Source.first.id).to eq(params["id"])
        expect(Source.first.uid).to eq(params["uid"])
        expect(Source.first.enabled).to be_falsey
      end
    end

    context "when source_type_id does not match the environment" do
      let(:params) { {'id' => 200, 'uid' => SecureRandom.uuid, 'name' => 'xyz'} }

      it "should do nothing" do
        subject.process
        expect(Source.count).to eq(0)
      end
    end
  end
end
