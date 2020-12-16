class KafkaListener
  attr_accessor :messaging_client_options, :service_name, :group_ref

  def initialize(messaging_client_options, service_name, group_ref)
    self.messaging_client_options = default_messaging_options.merge(messaging_client_options)
    self.service_name = service_name
    self.group_ref = group_ref
  end

  def run
    Thread.new { subscribe }
  end

  def subscribe
    ManageIQ::Messaging::Client.open(messaging_client_options) do |client|
      client.subscribe_topic(
        :service     => service_name,
        :persist_ref => group_ref,
        :max_bytes   => 500_000
      ) do |event|
        raw_process(event)
      end
    end
  rescue => e
    Rails.logger.error(["Something is wrong with Kafka client: ", e.message, *e.backtrace].join($RS))
    retry
  end

  private

  def raw_process(event)
    Rails.logger.info("Kafka message #{event.message} received with payload: #{event.payload}")

    ActiveRecord::Base.connection_pool.with_connection do
      process_event(event)
    end
  rescue => e
    Rails.logger.error(["Error processing event: ", e.message, *e.backtrace].join($RS))
  ensure
    event.ack
  end

  def default_messaging_options
    {:protocol => :Kafka, :encoding => 'json'}
  end
end
