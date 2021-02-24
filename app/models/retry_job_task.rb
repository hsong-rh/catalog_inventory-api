class RetryJobTask < LaunchJobTask
  after_update :post_retry_job_task, :if => proc { state == 'completed' }

  def post_retry_job_task
    original_task = LaunchJobTask.find_by(:child_task_id => id)
    raise "Can't find original task for retry task #{id}" if original_task.blank?

    if original_task.state != 'completed'
      update_task(original_task)
    end
  end

  private

  def update_task(task)
    task.with_lock("FOR UPDATE NOWAIT") do
      task.output = output
      task.state  = 'completed'
      task.status = 'ok'
      task.save!
    end
  rescue ActiveRecord::LockWaitTimeout
    Rails.logger.error("Task #{task.id} is locked for updating")
    raise CatalogInventory::Exceptions::RecordLockedException, "Task #{Task.id} is locked"
  end
end
