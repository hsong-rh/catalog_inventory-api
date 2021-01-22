require 'mqtt'

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
    Rails.logger.info("publish: #{payload}")
    publish
  end

  private



  def validate_options
    unless @options[:task_id].present? && @options[:task_url].present? && @options[:mqtt_client_url].present? && @options[:mqtt_client_guid].present?
      raise("Options must have task_id, task_url, mqtt_client_url and mqtt_client_guid keys")
    end
  end

  def publish
    u = URI.parse(@mqtt_client_url)
    client = MQTT::Client.new
    if u.scheme == "mqtts"
      client.ssl = true
    end
    client.host = u.host
    client.port = u.port
    client.connect
    ### Publlish a message on the topic "/paho/ruby/test" with "retain == false" and "qos == 1"
    client.publish("out/#{@mqtt_client_guid}", "#{payload}", false, 1)

    sleep 1
    client.disconnect
  rescue => error
    Rails.logger.error("Error publishing MQTT Message #{@mqtt_client_guid} #{error}")
  end

  def payload
    {}.tap do |obj|
      obj["url"] = "#{@task_url}/#{@task_id}"
      obj["kind"] = "catalog"
      obj["sent"] = Time.now.utc
    end.to_json
  end
end
