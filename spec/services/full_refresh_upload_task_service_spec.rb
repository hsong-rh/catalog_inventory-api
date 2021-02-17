describe FullRefreshUploadTaskService do
  include ::Spec::Support::TenantIdentity

  let(:params) { {'external_tenant' => tenant.external_tenant, :source_id => source.id} }
  let(:subject) { described_class.new(params) }

  around do |example|
    Insights::API::Common::Request.with_request(default_request) { example.call }
  end

  describe "#process" do
    before do
      allow(ClowderConfig).to receive(:instance).and_return({"UPLOAD_URL" => "http://www.upload_url.com"})
    end

    context "when source is disabled" do
      let(:source) { FactoryBot.create(:source, :tenant => tenant, :enabled => false) }

      it "returns FullRefreshUploadTaskService" do
        service = subject.process

        expect(service.class).to eq(FullRefreshUploadTaskService)
      end
    end

    context "when source has no sha and size" do
      let(:source) { FactoryBot.create(:source, :tenant => tenant, :enabled => true) }

      it "returns FullRefreshUploadTask" do
        task = subject.process.task

        expect(task.type).to eq('FullRefreshUploadTask')
        expect(task.input["response_format"]).to eq('tar')
        expect(task.input["jobs"].count).to eq(6)
        expect(task.input["upload_url"]).to eq('http://www.upload_url.com')
        expect(task.input["previous_sha"]).to be_nil
        expect(task.input["previous_size"]).to be_nil
        expect(task.state).to eq('pending')
        expect(task.status).to eq('ok')
      end
    end

    context "when source has sha and size" do
      let(:source) { FactoryBot.create(:source, :tenant => tenant, :previous_sha => 'sha256', :previous_size => 100, :enabled => true) }

      it "returns FullRefreshUploadTask" do
        task = subject.process.task

        expect(task.type).to eq('FullRefreshUploadTask')
        expect(task.input["response_format"]).to eq('tar')
        expect(task.input["jobs"].count).to eq(6)
        expect(task.input["upload_url"]).to eq('http://www.upload_url.com')
        expect(task.input["previous_sha"]).to eq('sha256')
        expect(task.input["previous_size"]).to eq(100)
        expect(task.state).to eq('pending')
        expect(task.status).to eq('ok')
      end
    end
  end
end
