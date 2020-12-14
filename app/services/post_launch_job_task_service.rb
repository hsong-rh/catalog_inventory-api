class PostLaunchJobTaskService < TaskService
  attr_reader :task

  def process
    @task = PostLaunchJobTask.create!(task_options)
    self
  end

  def task_options
    {}
  end
end
