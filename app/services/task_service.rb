class TaskService
  TOWER_API_VERSION = "api/v2".freeze

  def initialize(params)
    @params = params
  end

  private

  def task_input
    CatalogInventory::Payload.new(response_format, upload_url, jobs).as_json
  end

  def upload_url
    nil
  end

  def tenant
    Tenant.find_by(:external_tenant => @params.require(:external_tenant))
  end

  def source_id
    @params.require(:source_id)
  end

  def fetch_related
    [{:href_slug => "survey_spec", :predicate => "survey_enabled"}]
  end
end
