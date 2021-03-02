describe TowingTaskService do
  include ::Spec::Support::TenantIdentity

  let(:source) { FactoryBot.create(:source, :tenant => tenant) }
  let(:params) { {'source_id' => source.id} }
  let(:subject) { described_class.new(params) }
  let!(:launch_job_task) { LaunchJobTask.create!(:name => "task", :state => "running", :status => "ok", :tenant => tenant, :source => source, :input => input, :output => {"url" => "api/v1/url"}) }
  let(:time_interval) { ClowderConfig.instance["INACTIVE_TASK_REMINDER_TIME"] * 60 }
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

    shared_examples_for "#process bad output" do
      it "updates LaunchJobTask state and status" do
        Timecop.travel(Time.current + time_interval) do
          expect(KafkaEventService).to receive(:raise_event).once

          subject.process
          launch_job_task.reload

          expect(launch_job_task.status).to eq("error")
          expect(launch_job_task.state).to eq("completed")
          expect(TowingTask.count).to eq(0)
        end
      end
    end

    context "LaunchJobTask has no output" do
      let(:launch_job_task) { LaunchJobTask.create!(:name => "task", :state => "running", :status => "ok", :tenant => tenant, :source => source, :input => input) }

      it_behaves_like "#process bad output"
    end

    context "LaunchJobTask has no url output" do
      let(:launch_job_task) { LaunchJobTask.create!(:name => "task", :state => "running", :status => "ok", :tenant => tenant, :source => source, :input => input, :output => {"message" => "bad"}) }

      it_behaves_like "#process bad output"
    end

    context "LaunchJobTask has completed state" do
      let(:launch_job_task) { LaunchJobTask.create!(:name => "task", :state => "completed", :status => "ok", :tenant => tenant, :source => source, :input => input, :output => {"message" => "bad"}) }

      it "nothing happens" do
        Timecop.travel(Time.current + time_interval) do
          subject.process
          launch_job_task.reload

          expect(TowingTask.count).to eq(0)
        end
      end
    end

    context "starts a new retry task" do
      ["pending", "running"].each do |state|
        let(:launch_job_task) { LaunchJobTask.create!(:name => "task", :state => state, :status => "ok", :tenant => tenant, :source => source, :input => input, :output => {"url" => "api/v1/url"}) }

        it "for #{state} " do
          Timecop.travel(Time.current + time_interval) do
            subject.process
            launch_job_task.reload

            towing_task = TowingTask.find_by(:child_task_id => launch_job_task.id)
            expect(launch_job_task.message).to eq("Inactive, need towing task to reactivate")
            expect(towing_task.input["jobs"].first["method"]).to eq("monitor")
            expect(towing_task.input["jobs"].first["href_slug"]).to eq(launch_job_task.output["url"])
          end
        end
      end
    end

    it "No towing task is created due to short Time interval" do
      Timecop.travel(Time.current + 15 * 60) do
        subject.process
        launch_job_task.reload

        expect(launch_job_task.status).to eq("ok")
        expect(launch_job_task.state).to eq("running")
        expect(TowingTask.count).to eq(0)
      end
    end
  end
end
