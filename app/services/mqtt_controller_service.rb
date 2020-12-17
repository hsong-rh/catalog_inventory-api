class MQTTControllerService < TaskService
  def initialize(options)
    super

    @task_id  = options[:task_id] || raise("Missing task_id")
    @task_url = options[:task_url] || raise("Missing task_url")
    @mqtt_client_guid = options[:mqtt_client_guid] || raise("Missing mqtt_client_guid")
    @mqtt_client_url  = options[:mqtt_client_url] || raise("Missing mqtt_client_url")
  end

  def process
    system(publish)
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
