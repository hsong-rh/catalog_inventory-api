class KafkaEventService
  def self.raise_event(service, event, payload, headers = nil)
    publish_opts = {
      :service => service,
      :event   => event,
      :payload => payload,
      :headers => headers || Insights::API::Common::Request.current_forwardable
    }

    CatalogInventory::Api::Messaging.client.publish_topic(publish_opts)

    Rails.logger.info("Topic: #{service}, event: #{event}, payload: #{payload} is published")
  end
end
