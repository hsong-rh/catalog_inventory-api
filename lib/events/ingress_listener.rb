module Events
  class IngressListener < KafkaListener
    SERVICE_NAME = "platform.upload.catalog".freeze
    GROUP_REF = "catalog_inventory-api".freeze

    def initialize(messaging_client_option)
      super(messaging_client_option, SERVICE_NAME, GROUP_REF)
    end

    private

    def process_event(event)
      headers = {}
      headers["x-rh-identity"] = event.payload["b64_identity"]

      EventRouter.dispatch("Catalog.upload", event.payload, headers)
    rescue
      # TODO handle error
    end
  end
end
