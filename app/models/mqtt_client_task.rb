class MqttClientTask < Task
  def dispatch
    opts = {:task_id          => id,
            :task_url         => "http://localhost:5000/api/catalog-inventory/v3.0/tasks",
            # TODO: source.mqtt_client_guid
            :mqtt_client_guid => "123456789",
            :mqtt_client_url  => "mqtt://localhost:1883"}

    MQTTControllerService.new(opts).process
  end
end
