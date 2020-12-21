class PostRefreshUploadTaskService < TaskService
  def process
    create_kafka_event
    self
  end

  private

  def create_kafka_event
    CatalogInventory::Api::Messaging.client.publish_topic(
      :service => "platform.catalog.persister",
      # TODO: what's event??
      :event   => "Task.upload",
      :payload => kafka_payload,
      :headers => Insights::API::Common::Request.current_forwardable
    )

    Rails.logger.info("event(Task.update) published to kafka.")
  end

  # TODO: populate payload
  def kafka_payload
    {:params => {}}
  end
end
