describe SourceCreateTaskService do
  include ::Spec::Support::TenantIdentity

  let(:params) { {'source_id' => '200', 'external_tenant' => tenant.external_tenant, 'source_uid' => SecureRandom.uuid} }
  let(:subject) { described_class.new(params) }

  around do |example|
    Insights::API::Common::Request.with_request(default_request) { example.call }
  end

  describe "#process" do
    it "should create a ServiceInstance" do
      subject.process

      expect(Source.count).to eq(1)
      expect(Source.first.id.to_s).to eq(params["source_id"])
      expect(Source.first.uid).to eq(params["source_uid"])
    end
  end
end
