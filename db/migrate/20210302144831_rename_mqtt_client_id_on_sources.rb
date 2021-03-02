class RenameMqttClientIdOnSources < ActiveRecord::Migration[5.2]
  def change
    rename_column :sources, :mqtt_client_id, :cloud_connector_id
  end
end
