class PersisterTaskService
  def initialize(options)
    @options = JSON.parse(options).deep_symbolize_keys
    @upload_task = Task.find(@options[:category])
  end

  def process
    @task = FullRefreshPersisterTask.create!(opts)
    create_kafka_event

    self
  end

  def create_kafka_event
    CatalogInventory::Api::Messaging.client.publish_topic(
      :service => "platform.catalog.persister",
      :event   => "persister",
      :payload => payload,
      :headers => Insights::API::Common::Request.current_forwardable
    )

    Rails.logger.info("payload: #{payload}")
    Rails.logger.info("event(Task.update) published to kafka.")
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
    app_version = "v3.0"

   File.join(host, ENV["PATH_PREFIX"], ENV["APP_NAME"], app_version, "tasks", @task.id).gsub(/^\/+|\/+$/, "")
  end
end
