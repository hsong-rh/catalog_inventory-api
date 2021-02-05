describe PersisterTaskService do
  include ::Spec::Support::TenantIdentity

  let(:params) { JSON({'url' => 'http://example.com', 'size' => 1000, 'category' => task.id}) }
  let(:task) { FactoryBot.create(:task, :source => source, :tenant => tenant) }
  let(:subject) { described_class.new(params) }

  around do |example|
    Insights::API::Common::Request.with_request(default_request) { example.call }
  end

  describe "#process" do
    context "when source is enabled" do
      let(:source) { FactoryBot.create(:source, :enabled => true, :tenant => tenant) }

      it "should create a FullRefreshPersisterTask" do
        expect(CatalogInventory::Api::Messaging.client).to receive(:publish_topic)

        subject.process

        expect(Task.where(:type => "FullRefreshPersisterTask").count).to eq(1)
      end
    end

    context "when source is enabled" do
      let(:source) { FactoryBot.create(:source, :enabled => false, :tenant => tenant) }

      it "should not create a FullRefreshPersisterTask" do
        expect(CatalogInventory::Api::Messaging.client).not_to receive(:publish_topic)

        subject.process

        expect(Task.where(:type => "FullRefreshPersisterTask").count).to eq(0)
      end
    end
  end
end
