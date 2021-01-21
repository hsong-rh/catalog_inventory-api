describe SourceDestroyTaskService do
  include ::Spec::Support::TenantIdentity

  let!(:source) { FactoryBot.create(:source, :tenant => tenant) }
  let(:params) { {'source_id' => source.id, 'source_type_id' => "10"} }
  let(:subject) { described_class.new(params) }

  before do
    allow(ClowderConfig).to receive(:instance).and_return({"SOURCE_TYPE_ID" => "10"})
  end

  describe "#process" do
    it "should destroy the Source" do
      expect(Source.count).to eq(1)
      subject.process
      expect(Source.count).to eq(0)
    end
  end
end
