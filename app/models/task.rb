class Task < ApplicationRecord
  belongs_to :tenant
  belongs_to :source, :optional => true

  validates :state,  :inclusion => {:in => %w(pending queued running completed)}
  validates :status, :inclusion => {:in => %w(ok warn error)}

  acts_as_tenant(:tenant)

  after_update :post_launch_job_task, :if => proc { type == 'LaunchJobTask' && state == 'completed' }

  def post_launch_job_task
    PostLaunchJobTaskService.new(service_options).process
  end

  def service_options
  end

  def dispatch
  end
end
