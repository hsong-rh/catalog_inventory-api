describe PostLaunchJobTaskService do
  include ::Spec::Support::TenantIdentity

  let(:source) { FactoryBot.create(:source, :tenant => tenant) }
  let(:params) { {'source_id' => source.id, 'tenant_id' => tenant.id, 'source_ref' => SecureRandom.uuid} }
  let(:subject) { described_class.new(params) }

  around do |example|
    Insights::API::Common::Request.with_request(default_request) { example.call }
  end

  describe "#process" do
    xit "should create a ServiceInstance" do
      expect(CatalogInventory::Api::Messaging.client).to receive(:publish_topic)

      subject.process

      expect(ServiceInstance.count).to eq(1)
      expect(ServiceInstance.first.source_ref).to eq(params["source_ref"])
    end
  end
end
