class PostCheckAvailabilityTaskService < TaskService
  STATUS_AVAILABLE, STATUS_UNAVAILABLE = %w[available unavailable].freeze
  EVENT_AVAILABILITY_STATUS            = "availability_status".freeze
  SERVICE_NAME                         = "platform.sources.status".freeze

  def initialize(options)
    super
    @source = Source.find(options[:source_id]) || raise("source_id must be specified in options")
    @task   = CheckAvailabilityTask.find(options[:task_id]) || raise("task_id must be specified")
  end

  def process
    update_source
    KafkaEventService.raise_event(SERVICE_NAME, EVENT_AVAILABILITY_STATUS, kafka_payload)
    create_refresh_upload_task if @task.status == "ok"
    self
  end

  private

  def update_source
    update_opts = {:availability_status => source_status, :last_checked_at => @task.created_at}
    update_opts.merge!(:last_available_at => @task.created_at, :info => @options[:output]) if @task.status == "ok"

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
