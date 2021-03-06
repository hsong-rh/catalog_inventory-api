class TaskService
  TOWER_API_VERSION = "api/v2".freeze

  def initialize(options)
    @options = options.deep_symbolize_keys
    validate_options
  end

  private

  def validate_options
    raise("Options must have source_id") if @options[:source_id].blank?
  end

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

  def source_enabled?
    Source.find_by(:id => source_id)&.enabled
  end

  def source_refresh?
    Source.find_by(:id => source_id)&.mqtt_client_id.nil? || !source_enabled?
  end

  def fetch_related
    [{:href_slug => "survey_spec", :predicate => "survey_enabled"}]
  end
end
