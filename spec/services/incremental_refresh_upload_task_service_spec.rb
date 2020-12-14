describe IncrementalRefreshUploadTaskService do
  include ::Spec::Support::TenantIdentity

  let(:source) { FactoryBot.create(:source, :tenant => tenant) }
  let(:params) { ActionController::Parameters.new('external_tenant' => tenant.external_tenant, :source_id => source.id, :last_successful_refresh_at => Time.current.to_s) }
  let(:subject) { described_class.new(params) }

  around do |example|
    with_modified_env(:UPLOAD_URL => "http://www.upload_url.com") do
      Insights::API::Common::Request.with_request(default_request) { example.call }
    end
  end

  describe "#process" do
    it "returns IncrementalRefreshUploadTask" do
      task = subject.process.task

      expect(task.type).to eq('IncrementalRefreshUploadTask')
      expect(task.input["response_format"]).to eq('tar')
      expect(task.input["jobs"].count).to eq(12)
      expect(task.input["upload_url"]).to eq('http://www.upload_url.com')
      expect(task.state).to eq('pending')
      expect(task.status).to eq('ok')
    end
  end
end
