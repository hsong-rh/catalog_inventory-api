class PostLaunchJobTaskService < TaskService
  def process
    create_service_instance
    ActiveRecord::Base.connection().commit_db_transaction unless Rails.env.test?
    KafkaEventService.raise_event("platform.catalog-inventory.task-output-stream", "Task.update", kafka_payload)

    self
  end

  private

  def validate_options
    raise("Options must have source_ref key") if @options[:source_ref].blank?
  end

  def create_service_instance
    instance = ServiceInstance.create!(@options)
    Rails.logger.info("ServiceInstance##{instance.id} is created.")
  end

  # TODO: populate payload
  def kafka_payload
    {:params => {}}
  end
end
