class PostLaunchJobTaskService < TaskService
  def process
    create_service_instance
    KafkaEventService.raise_event("platform.catalog-inventory.task-output-stream", "Task.update", kafka_payload)

    self
  end

  private

  def create_service_instance
    instance = ServiceInstance.create!(@options)
    Rails.logger.info("ServiceInstance##{instance.id} is created.")
  end

  # TODO: populate payload
  def kafka_payload
    {:params => {}}
  end
end
