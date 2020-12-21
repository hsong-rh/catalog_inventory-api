class CheckAvailabilityTaskService < TaskService
  attr_reader :task

  def process
    validate_options
    @task = CheckAvailabilityTask.create!(task_options)

    self
  rescue => e
    Rails.logger.error("Failed to create task: #{e.message}")
  end

  private

  def validate_options
    raise("Options must have source_id and external_tenant keys") unless @options[:params].present? && @options.dig(:params, :source_id).present? && @options.dig(:params, :external_tenant).present?
  end

  def response_format
    "json"
  end

  def task_options
    {}.tap do |options|
      options[:tenant] = tenant
      options[:source_id] = source_id
      options[:state] = 'pending'
      options[:status] = 'ok'
      options[:forwardable_headers] = Insights::API::Common::Request.current_forwardable
      options[:input] = task_input
    end
  end

  def tenant
    Tenant.find_by(:external_tenant => @options[:params][:external_tenant])
  end

  def source_id
    @options[:params][:source_id]
  end

  def jobs
    jobs = []

    check_availability_job = CatalogInventory::Job.new
    check_availability_job.href_slug = "api/v2/config/"
    check_availability_job.method = "get"
    check_availability_job.apply_filter = {"version":"version", "ansible_version":"ansible_version"}
    jobs << check_availability_job

    jobs
  end
end
