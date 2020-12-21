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
    # TODO: need to add two columns to save available status
    update_source
    create_kafka_event
    create_refresh_upload_task if @task.status == "ok"
    self
  end

  private

  def update_source
    @source.update!(:info => @options[:output])
  end

  def create_kafka_event
    CatalogInventory::Api::Messaging.client.publish_topic(
      :service => SERVICE_NAME,
      :event   => EVENT_AVAILABILITY_STATUS,
      :payload => kafka_payload,
      :headers => Insights::API::Common::Request.current_forwardable
    )

    Rails.logger.info("event(Task.update) published to kafka.")
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
                    IncrementalRefreshUploadTaskService.new(opts.merge!(:last_successful_refresh_at => @source.last_successful_refresh_at)).process.task
                  else
                    FullRefreshUploadTaskService.new(opts).process.task
                  end

    upload_task.dispatch
  end
end
