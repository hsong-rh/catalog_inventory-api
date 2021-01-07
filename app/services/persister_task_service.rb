class PersisterTaskService
  def initialize(options)
    @options = JSON.parse(options).deep_symbolize_keys

    validate_options
    @upload_task = Task.find(@options[:category])
  end

  def process
    @task = FullRefreshPersisterTask.create!(opts)
    KafkaEventService.raise_event("platform.catalog.persister", "persister", payload)

    self
  end

  private

  def validate_options
    unless @options[:category].present? && @options[:url].present? && @options[:size].present?
      raise("Options must have category, url and size keys")
    end
  end

  def opts
    {}.tap do |options|
      options[:tenant_id] = @upload_task.tenant_id
      options[:source_id] = @upload_task.source_id
      options[:input] = input
      options[:state] = 'pending'
      options[:status] = 'ok'
    end
  end

  def input
    {}.tap do |options|
      options[:refresh_request_at] = @upload_task.created_at
      options[:data_url] = @options[:url]
      options[:size] = @options[:size]
    end
  end

  def payload
    input.merge!(:tenant_id => @upload_task.tenant_id, :source_id => @upload_task.source_id, :task_url => task_url)
  end

  def task_url
    host = ENV.fetch("CATALOG_INVENTORY_INTERNAL_URL")
    app_version = ENV["CURRENT_API_VERSION"] || "v3.0"

    File.join(host, ENV["PATH_PREFIX"], ENV["APP_NAME"], app_version, "tasks", @task.id).gsub(/^\/+|\/+$/, "")
  end
end
