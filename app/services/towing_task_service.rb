class TowingTaskService < TaskService
  INACTIVE_TASK_REMINDER_TIME = ClowderConfig.instance["INACTIVE_TASK_REMINDER_TIME"].to_i * 60
  INCOMPLETE_TASK_STATES = %w[pending running].freeze

  def process
    inactive_tasks.each do |task|
      if task.output.blank? || task.output["url"].blank?
        Rails.logger.error("No need to tow the task #{task.inspect}")
        task.update!(:state => "completed", :status => "error")
        continue
      end

      towing_task = TowingTask.create!(task_options(task))
      towing_task.dispatch

      Rails.logger.info("Towing the inactive task: #{task}")
      task.update!(:message => "Inactive, need towing task to reactivate")
    end

    self
  rescue => e
    Rails.logger.error("Towing task failed: #{e.message}")
  end

  private

  def inactive_tasks
    tasks = Task.arel_table
    LaunchJobTask.where(tasks[:created_at].lt(Time.current - INACTIVE_TASK_REMINDER_TIME).and(tasks[:state].in(INCOMPLETE_TASK_STATES)).and(tasks[:source_id].eq(@source.id)))
  end

  def task_options(task)
    {}.tap do |opts|
      opts[:child_task_id] = task.id
      opts[:forwardable_headers] = task.forwardable_headers
      opts[:source_id] = task.source.id
      opts[:tenant] = task.tenant
      opts[:state]  = 'pending'
      opts[:status] = 'ok'
      opts[:input] = input(task)
    end
  end

  def input(task)
    CatalogInventory::Payload.new('json', upload_url, jobs(task)).as_json
  end

  def jobs(task)
    jobs = []

    launch = CatalogInventory::Job.new
    launch.href_slug = task.output["url"]
    launch.method = "monitor"
    launch.apply_filter = {"id":"id", "status":"status", "started":"started", "url":"url", "type":"type","finished":"finished", "modified":"modified", "description":"description", "extra_vars":"extra_vars", "artifacts":"artifacts", "name":"name","created":"created", "unified_job_template":"unified_job_template"}
    jobs << launch

    jobs
  end
end
