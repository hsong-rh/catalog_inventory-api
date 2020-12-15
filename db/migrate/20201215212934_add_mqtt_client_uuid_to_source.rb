class AddMqttClientUuidToSource < ActiveRecord::Migration[5.2]
  def change
    add_column :sources, :mqtt_client_id, :string
  end
end
