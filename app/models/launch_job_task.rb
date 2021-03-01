class LaunchJobTask < MqttClientTask
  after_update :post_launch_job_task, :if => proc { state == 'completed' && status == 'ok' }

  def post_launch_job_task
    if tower_job_successful?
      PostLaunchJobTaskService.new(service_options).process
    else
      self.status = 'error'
      self.message = output["description"] if output.present?
      save!

      Rails.logger.error("Task #{id} failed: #{output}")
    end
  end

  def tower_job_successful?
    output.present? && output["status"] == "successful"
  end

  def towing_tasks
    TowingTask.where(:child_task_id => id)
  end

  def service_options
    super.tap do |options|
      options[:service_offering_id] = service_offering.id.to_s
      options[:service_plan_id] = service_plan_id.to_s
      options[:external_url] = output["url"]
      options[:source_ref] = output["id"]
      options[:name] = output["name"]
      options[:source_created_at] = output["created"]
      options[:extra] = extra
    end.except(:task)
  end

  def extra
    {}.tap do |e|
      e[:status] = output["status"]
      e[:started] = output["started"]
      e[:finished] = output["finished"]
      e[:extra_vars] = output["extra_vars"]
      e[:artifacts] = output["artifacts"]
    end
  end

  def service_offering
    @service_offering ||= ServiceOffering.find_by(:source_ref => output["unified_job_template"].to_s) || raise("Unable to find ServiceOffering")
  end

  def service_plan_id
    # Not all service offerings have service plans
    service_offering.service_plans.first.try(:id)
  end
end
