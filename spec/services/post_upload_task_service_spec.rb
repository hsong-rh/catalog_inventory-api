describe PostUploadTaskService do
  include ::Spec::Support::TenantIdentity

  let(:source) { FactoryBot.create(:source, :tenant => tenant) }
  let(:task) { FactoryBot.create(:task, :source => source, :tenant => tenant, :status => status, :message => message, :output => output) }
  let(:params) { {'source_id' => source.id, 'tenant_id' => tenant.id, 'task' => task} }
  let(:subject) { described_class.new(params) }

  around do |example|
    Insights::API::Common::Request.with_request(default_request) { example.call }
  end

  context "when task status is unchanged" do
    let(:status) { "unchanged" }
    let(:message) { "Upload skipped since nothing has changed" }

    it "updates source" do
      subject.process
      source.reload

      expect(source.refresh_state).to eq("Done")
      expect(source.last_refresh_message).to eq(message)
    end
  end

  context "when task status is unchanged" do
    let(:status) { "error" }
    let(:message) { "" }
    let(:output) { {"errors" => ["kaboom", "failed miserably"]} }

    it "updates source" do
      subject.process
      source.reload

      expect(source.refresh_state).to eq("Error")
      expect(source.last_refresh_message).to eq("kaboom\nfailed miserably")
    end
  end
end
