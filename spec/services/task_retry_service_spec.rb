describe TaskRetryService do
  include ::Spec::Support::TenantIdentity

  let(:source) { FactoryBot.create(:source, :tenant => tenant) }
  let(:params) { {'source_id' => source.id} }
  let(:subject) { described_class.new(params) }
  let!(:launch_job_task) { LaunchJobTask.create!(:name => "task", :state => "running", :status => "ok", :tenant => tenant, :source => source, :input => input) }
  let!(:retry_task) { LaunchJobTask.create!(:name => "retry_task", :state => "pending", :status => "ok", :tenant => tenant, :source => source) }
  let(:time_interval) { ClowderConfig.instance["LOST_TIME_INTERVAL"] * 60 }
  let(:input) { {"jobs" => [{"method" => "launch", "href_slug" => "api/v2/job_templates/5/launch/"}]} }

  around do |example|
    Insights::API::Common::Request.with_request(default_request) { example.call }
  end

  describe "#process" do
    let(:service) { instance_double(MQTTControllerService) }

    before do
      Timecop.safe_mode = true
      allow(MQTTControllerService).to receive(:new).and_return(service)
      allow(service).to receive(:process)
    end

    it "starts a new retry task" do
      Timecop.travel(Time.current + time_interval) do
        subject.process
        launch_job_task.reload

        expect(launch_job_task.status).to eq("error")
        expect(launch_job_task.state).to eq("completed")
        expect(launch_job_task.message).to eq("interrupted")
        expect(Task.find(launch_job_task.child_task_id).input["jobs"].first["method"]).to eq("monitor")
      end
    end

    it "no interrupted tasks" do
      Timecop.travel(Time.current + 15 * 60) do
        subject.process
        launch_job_task.reload

        expect(launch_job_task.status).to eq("ok")
        expect(launch_job_task.state).to eq("running")
        expect(launch_job_task.child_task_id).to be_nil
      end
    end
  end
end
