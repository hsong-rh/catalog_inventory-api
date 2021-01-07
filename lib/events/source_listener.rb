module Events
  class SourceListener < KafkaListener
    SERVICE_NAME = "platform.sources.event-stream".freeze
    GROUP_REF = "catalog_inventory-api".freeze

    def initialize(messaging_client_option)
      super(messaging_client_option, SERVICE_NAME, GROUP_REF)
    end

    private

    def process_event(event)
      EventRouter.dispatch(event.message, event.payload)
    end
  end
end
