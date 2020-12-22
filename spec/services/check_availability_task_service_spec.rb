describe CheckAvailabilityTaskService do
  include ::Spec::Support::TenantIdentity

  let(:source) { FactoryBot.create(:source, :tenant => tenant) }
  let(:params) { {'external_tenant' => tenant.external_tenant, 'source_id' => source.id} }
  let(:subject) { described_class.new(params) }

  around do |example|
    Insights::API::Common::Request.with_request(default_request) { example.call }
  end

  describe "#process" do
    it "returns CheckAvailabilityTask type of task" do
      task = subject.process.task

      expect(task.type).to eq('CheckAvailabilityTask')
      expect(task.input["response_format"]).to eq('json')
      expect(task.input["jobs"]).to eq([{"apply_filter"=>{"ansible_version"=>"ansible_version", "version"=>"version"}, "href_slug"=>"api/v2/config/", "method"=>"get"}])
      expect(task.input["upload_url"]).to be_nil
      expect(task.state).to eq('pending')
      expect(task.status).to eq('ok')
    end
  end
end
