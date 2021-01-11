describe SourceCreateTaskService do
  include ::Spec::Support::TenantIdentity

  let(:subject) { described_class.new(params) }

  around do |example|
    with_modified_env(:SOURCE_TYPE_ID => "10") do
      Insights::API::Common::Request.with_request(default_request) { example.call }
    end
  end

  describe "#process" do
    context "when source_type_id matches the environment" do
      let(:params) { {'source_id' => '200', 'source_type_id' => "10", 'external_tenant' => tenant.external_tenant, 'source_uid' => SecureRandom.uuid} }

      it "should create a ServiceInstance" do
        subject.process

        expect(Source.count).to eq(1)
        expect(Source.first.id.to_s).to eq(params["source_id"])
        expect(Source.first.uid).to eq(params["source_uid"])
        expect(Source.first.enabled).to be_falsey
      end
    end

    context "when source_type_id doee not matches the environment" do
      let(:params) { {'source_id' => '200', 'external_tenant' => tenant.external_tenant, 'source_uid' => SecureRandom.uuid} }

      it "should do nothing" do
        subject.process
        expect(Source.count).to eq(0)
      end
    end
  end
end
