class TowerOperationListener < KafkaListener
  # TODO: will change later after source side updates to catalog-inventory
  SERVICE_NAME = "platform.topological-inventory.operations-ansible-tower".freeze
  GROUP_REF = "catalog_inventory-api".freeze

  def initialize(messaging_client_option)
    super(messaging_client_option, SERVICE_NAME, GROUP_REF)
  end

  private

  def process_event(event)
    # TODO add logic here
  rescue
    # TODO handle error
  end
end
