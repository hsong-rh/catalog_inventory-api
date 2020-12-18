module Events
  class TowerOperationListener < KafkaListener
    SERVICE_NAME = "platform.topological-inventory.operations-ansible-tower".freeze
    GROUP_REF = "catalog_inventory-api".freeze

    def initialize(messaging_client_option)
      super(messaging_client_option, SERVICE_NAME, GROUP_REF)
    end

    private

    def process_event(event)
      EventRouter.dispatch(event.message, event.payload, event.headers)
    rescue
      # TODO handle error
    end
  end
end
