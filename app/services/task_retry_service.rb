class TaskRetryService < TaskService
  LOST_TIME_INTERVAL = ClowderConfig.instance["LOST_TIME_INTERVAL"].to_i * 60

  def process
    interrupted_tasks.each do |task|
      retry_task = LaunchJobTask.create!(task_options(task))
      retry_task.dispatch

      Rails.logger.info("Retry the interrupted task: #{task}")
      task.update!(:state => "completed", :status => "error", :message => "interrupted", :child_task_id => retry_task.id)
    end

    self
  rescue => e
    Rails.logger.error("Retry task failed: #{e.message}")
  end

  private

  def interrupted_tasks
    tasks = Task.arel_table
    Task.where(tasks[:created_at].lt(Time.current - LOST_TIME_INTERVAL).and(tasks[:type].eq("LaunchJobTask")).and(tasks[:state].eq("running")).and(tasks[:source_id].eq(@source.id)))
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
    job = task.input["jobs"].first
    job["method"] = 'monitor'
    task.input.merge!(:jobs => [job])
  end
end
