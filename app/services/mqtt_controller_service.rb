class MQTTControllerService
  def initialize(options)
    @options = options.deep_symbolize_keys

    validate_options
    @task_id  = @options[:task_id]
    @task_url = @options[:task_url]
    @mqtt_client_guid = @options[:mqtt_client_guid]
    @mqtt_client_url  = @options[:mqtt_client_url]
  end

  # TODO: will replace by the mqtt controller in cluster
  def process
    Rails.logger.info("publish: #{publish}")
    exit_status = system(publish)
    Rails.logger.info("exit_status: #{exit_status}")
  end

  private

  def validate_options
    unless @options[:task_id].present? && @options[:task_url].present? && @options[:mqtt_client_url].present? && @options[:mqtt_client_guid].present?
      raise("Options must have task_id, task_url, mqtt_client_url and mqtt_client_guid keys")
    end
  end

  def publish
    "mosquitto_pub -L #{@mqtt_client_url}/out/#{@mqtt_client_guid} -m '" + "#{payload}'"
  end

  def payload
    {}.tap do |obj|
      obj["url"] = "#{@task_url}/#{@task_id}"
      obj["kind"] = "catalog"
      obj["sent"] = Time.now.utc
    end.to_json
  end
end
