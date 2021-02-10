class PostCheckAvailabilityTaskService < TaskService
  STATUS_AVAILABLE, STATUS_UNAVAILABLE = %w[available unavailable].freeze

  def initialize(options)
    super
    @source = Source.find(@options[:source_id])
    @task   = @options[:task]
  end

  def process
    update_source
    KafkaEventService.raise_event("platform.sources.status", "availability_status", kafka_payload.to_json)
    @task.status == "ok" ? create_refresh_upload_task : Rails.logger.error("Task #{@task.id} failed")
    self
  end

  private

  def validate_options
    super
    raise("Options must have task key") if @options[:task].blank?
  end

  def update_source
    update_opts = {:availability_status => source_status, :last_checked_at => @task.created_at.iso8601}
    update_opts.merge!(:last_available_at => @task.created_at.iso8601, :info => @options[:output]) if @task.status == "ok"

    @source.update!(update_opts)
  end

  def kafka_payload
    {
      :resource_type => "Source",
      :resource_id   => @source.id,
      :status        => source_status
    }
  end

  def source_status
    @task.status == "ok" ? STATUS_AVAILABLE : STATUS_UNAVAILABLE
  end

  def create_refresh_upload_task
    opts = {:tenant_id => @options[:tenant_id], :source_id => @source.id}

    upload_task = if @source.last_successful_refresh_at.present?
                    IncrementalRefreshUploadTaskService.new(opts.merge!(:last_successful_refresh_at => @source.last_successful_refresh_at.iso8601)).process.task
                  else
                    FullRefreshUploadTaskService.new(opts).process.task
                  end

    upload_task.dispatch
  end
end
