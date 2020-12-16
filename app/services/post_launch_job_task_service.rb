class PostLaunchJobTaskService < TaskService
  def process
    create_service_instance
    create_kafka_event

    self
  end

  private

  def create_service_instance
    instance = ServiceInstance.create!(service_instance_options)
    Rails.logger.info("ServiceInstance##{instance.id} is created.")
  end

  def create_kafka_event
    if ENV['NO_KAFKA'].blank?
      CatalogInventory::Api::Messaging.client.publish_topic(
        :service => "platform.catalog-inventory.task-output-stream",
        # TODO: what's event??
        :event   => "Task.update",
        :payload => kafka_payload,
        :headers => Insights::API::Common::Request.current_forwardable
      )

      Rails.logger.info("event(Task.update) published to kafka.")
    end
  end

  # TODO: populate input
  def service_instance_options
    @options.symbolize_keys.slice(:source_id, :tenant_id, :source_ref)
  end

  # TODO: populate payload
  def kafka_payload
    {:params => {}}
  end
end
