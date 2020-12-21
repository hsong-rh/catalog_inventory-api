class MqttClientTask < Task
  def dispatch
    host = ENV.fetch("CATALOG_INVENTORY_URL")
    mqtt_client_url = ENV.fetch("MQTT_CLIENT_URL")
    app_version = "v3.0"

    prefix = File.join(host, ENV["PATH_PREFIX"], ENV["APP_NAME"], app_version, "tasks").gsub(/^\/+|\/+$/, "")
    opts = {:task_id          => id,
            :task_url         => prefix,
            :mqtt_client_guid => source.mqtt_client_id,
            :mqtt_client_url  => mqtt_client_url}

    MQTTControllerService.new(opts).process
  end
end
