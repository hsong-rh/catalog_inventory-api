class CollectInventoriesService
  attr_reader :inventory_tags

  def initialize(service_offering_id)
    @service_offering_id = service_offering_id
    @inventory_tags = []
  end

  def process
    visited = []
    inventory_ids = []
    collect_inventory(@service_offering_id, visited, inventory_ids)
    @inventory_tags = inventory_ids.uniq.each.collect { |id| ServiceInventory.find(id).tags }.flatten

    self
  end

  private

  def collect_inventory(service_offering_id, visited, result)
    return if visited.include?(service_offering_id)

    visited << service_offering_id

    obj = ServiceOffering.find(service_offering_id)
    result << obj.service_inventory_id if obj.service_inventory_id
    process_children(obj.id, visited, result) if obj.extra["type"] == "workflow_job_template"
  end

  def process_children(root_id, visited, result)
    ServiceOfferingNode.where(:root_service_offering_id => root_id).each do |obj|
      # Special case for inventory defined in ServiceOfferingNode
      result << obj.service_inventory_id if obj.service_inventory_id
      collect_inventory(obj.service_offering_id, visited, result)
    end
  end
end
