class Task < ApplicationRecord
  belongs_to :tenant
  belongs_to :source, :optional => true

  validates :state,  :inclusion => {:in => %w(pending queued running completed)}
  validates :status, :inclusion => {:in => %w(ok warn error)}

  acts_as_tenant(:tenant)

  after_update :post_launch_job_task, :if => proc { type == 'LaunchJobTask' && state == 'completed' }

  def post_launch_job_task
    # TODO: populate opt
    opts = {:tenant_id => tenant.id, :source_id => source.id, :source_ref => SecureRandom.uuid}

    PostLaunchJobTaskService.new(opts).process
  end

  def dispatch
  end
end
