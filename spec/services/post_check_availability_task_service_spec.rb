describe PostCheckAvailabilityTaskService do
  include ::Spec::Support::TenantIdentity

  let(:source) { FactoryBot.create(:source, :tenant => tenant) }
  let(:task) { FactoryBot.create(:task, :source => source, :tenant => tenant, :output => output, :status => status) }
  let(:params) { {'source_id' => source.id, 'tenant_id' => tenant.id, :output => output, 'task' => task} }
  let(:subject) { described_class.new(params) }

  around do |example|
    Insights::API::Common::Request.with_request(default_request) { example.call }
  end

  describe "#process" do
    let(:service) { instance_double(SourceRefreshService) }
    before do
      allow(KafkaEventService).to receive(:raise_event)
      allow(SourceRefreshService).to receive(:new).and_return(service)
      allow(service).to receive(:process).and_return(service)
    end

    context "when check availability task status is ok" do
      let(:status) { "ok" }
      let(:output) { "task result" }

      it "source is updated" do
        subject.process
        source.reload

        expect(source.last_available_at).to eq(task.created_at.iso8601)
        expect(source.info).to eq(output)
        expect(source.availability_message).to be_nil
        expect(source.availability_status).to eq('available')
        expect(source.last_checked_at).to eq(task.created_at.iso8601)
      end
    end

    context "when check availability task status is error" do
      let(:status) { "error" }
      let(:output) { {"errors" => ["task", "failed"]} }

      it "source is updated" do
        subject.process
        source.reload

        expect(source.availability_message).to eq("task; failed")
        expect(source.availability_status).to eq('unavailable')
        expect(source.last_checked_at).to eq(task.created_at.iso8601)
      end
    end
  end
end
