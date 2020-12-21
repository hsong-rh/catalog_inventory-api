class CheckAvailabilityTask < MqttClientTask
  after_update :post_check_availability_task, :if => proc { type == 'CheckAvailabilityTask' && state == 'completed' }

  def post_check_availability_task
    PostCheckAvailabilityTaskService.new(service_options).process
  end

  def service_options
    {}.tap do |options|
      options[:tenant_id] = tenant.id
      options[:source_id] = source.id
      options[:task_id] = id
      options[:output] = output
    end
  end
end
