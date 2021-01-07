describe SourceDestroyTaskService do
  include ::Spec::Support::TenantIdentity

  let!(:source) { FactoryBot.create(:source, :tenant => tenant) }
  let(:params) { {'source_id' => source.id} }
  let(:subject) { described_class.new(params) }

  around do |example|
    Insights::API::Common::Request.with_request(default_request) { example.call }
  end

  describe "#process" do
    it "should destroy the Source" do
      expect(Source.count).to eq(1)
      subject.process
      expect(Source.count).to eq(0)
    end
  end
end
