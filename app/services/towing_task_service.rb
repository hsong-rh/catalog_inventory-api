class TowingTaskService < TaskService
  INACTIVE_TASK_REMINDER_TIME = ClowderConfig.instance["INACTIVE_TASK_REMINDER_TIME"].to_i * 60

  def process
    inactive_tasks.each do |task|
      towing_task = TowingTask.create!(task_options(task))
      towing_task.dispatch

      Rails.logger.info("Towing the inactive task: #{task}")
      task.update!(:message => "interrupted", :child_task_id => towing_task.id)
    end

    self
  rescue => e
    Rails.logger.error("Retry task failed: #{e.message}")
  end

  private

  def inactive_tasks
    tasks = Task.arel_table
    LaunchJobTask.where(tasks[:created_at].lt(Time.current - INACTIVE_TASK_REMINDER_TIME).and(tasks[:state].eq("running")).and(tasks[:source_id].eq(@source.id)))
  end

  def task_options(task)
    {}.tap do |opts|
      opts[:forwardable_headers] = task.forwardable_headers
      opts[:source_id] = task.source.id
      opts[:tenant] = task.tenant
      opts[:state]  = 'pending'
      opts[:status] = 'ok'
      opts[:input] = input(task)
    end
  end

  def input(task)
    CatalogInventory::Payload.new('json', upload_url, jobs(task), @source.previous_sha, @source.previous_size).as_json
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
