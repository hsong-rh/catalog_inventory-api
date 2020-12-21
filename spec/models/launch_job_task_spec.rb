describe LaunchJobTask do
  include ::Spec::Support::TenantIdentity

  let(:task) { LaunchJobTask.create!(:name => "task2", :tenant => tenant, :source => source) }
  let(:source) { Source.create!(:name => "source1", :tenant => tenant) }

  describe "after_update callback" do
    context "when LaunchJobTask has completed state" do
      let(:launch_job_task) { LaunchJobTask.create!(:name => "task", :state => "completed", :status => "ok", :tenant => tenant, :source => source) }

      it "calls post_launch_job_task" do
        expect(launch_job_task).to receive(:post_launch_job_task)

        launch_job_task.run_callbacks :update
      end
    end

    context "when LaunchJobTask's state is not completed" do
      let(:launch_job_task) { LaunchJobTask.create!(:name => "task", :state => "pending", :status => "ok", :tenant => tenant, :source => source) }

      it "no calls to post_launch_job_task" do
        expect(launch_job_task).to_not receive(:post_launch_job_task)

        launch_job_task.run_callbacks :update
      end
    end
  end
end
