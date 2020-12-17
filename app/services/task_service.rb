class TaskService
  TOWER_API_VERSION = "api/v2".freeze

  def initialize(options)
    @options = options.symbolize_keys
  end

  private

  def task_input
    CatalogInventory::Payload.new(response_format, upload_url, jobs).as_json
  end

  def upload_url
    nil
  end

  def tenant
    Tenant.find_by(:external_tenant => @options[:external_tenant])
  end

  def source_id
    @options[:source_id]
  end

  def fetch_related
    [{:href_slug => "survey_spec", :predicate => "survey_enabled"}]
  end
end
