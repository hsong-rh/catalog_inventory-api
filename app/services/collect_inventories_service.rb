class CollectInventoriesService
  attr_reader :inventory_ids

  def initialize(options)
    @options = options.deep_symbolize_keys
    @service_offering_id = @options[:service_offering_id]
    @task_id = @options[:task_id]
    @inventory_ids = []
  end

  def process
    Task.update(@task_id, :state => "running", :status => "ok")

    visited = []
    collect_inventory(@service_offering_id, visited, @inventory_ids)

    Task.update(@task_id, :state => "completed", :status => "ok", :output => {:applied_inventories => @inventory_ids})

    self
  rescue => e
    Rails.logger.error("Task #{@task_id} AppliedInventories error: #{e}\n#{e.backtrace.join("\n")}")
    Task.update(@task_id, :state => "completed", :status => "error", :output => {:error => e.to_s})
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
