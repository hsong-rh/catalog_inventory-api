class MqttClientTask < Task
  def dispatch
    host = ClowderConfig.instance["CATALOG_INVENTORY_URL"]
    mqtt_client_url = ClowderConfig.instance["MQTT_CLIENT_URL"]
    app_version = ClowderConfig.instance["CURRENT_API_VERSION"] || "v1.0"

    task_url_prefix = File.join(host, app_version, "tasks").gsub(/^\/+|\/+$/, "")
    opts = {:task_id          => id,
            :task_url         => task_url_prefix,
            :mqtt_client_guid => source.mqtt_client_id,
            :mqtt_client_url  => mqtt_client_url}

    Rails.logger.info("Getting connection to MQTT controller ...")
    MQTTControllerService.new(opts).process
  end
end
