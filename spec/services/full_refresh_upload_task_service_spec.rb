describe FullRefreshUploadTaskService do
  include ::Spec::Support::TenantIdentity

  let(:source) { FactoryBot.create(:source, :tenant => tenant, :enabled => true) }
  let(:params) { {'external_tenant' => tenant.external_tenant, :source_id => source.id} }
  let(:subject) { described_class.new(params) }

  around do |example|
    Insights::API::Common::Request.with_request(default_request) { example.call }
  end

  describe "#process" do
    before do
      allow(ClowderConfig).to receive(:instance).and_return({"UPLOAD_URL" => "http://www.upload_url.com"})
    end

    it "returns FullRefreshUploadTask" do
      task = subject.process.task

      expect(task.type).to eq('FullRefreshUploadTask')
      expect(task.input["response_format"]).to eq('tar')
      expect(task.input["jobs"].count).to eq(6)
      expect(task.input["upload_url"]).to eq('http://www.upload_url.com')
      expect(task.state).to eq('pending')
      expect(task.status).to eq('ok')
    end
  end
end
