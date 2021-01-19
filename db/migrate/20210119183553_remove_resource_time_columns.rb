class RemoveResourceTimeColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :service_credential_types, :resource_timestamp, :datetime
    remove_column :service_credential_types, :resource_timestamps, :jsonb
    remove_column :service_credential_types, :resource_timestamps_max, :datetime

    remove_column :service_credentials, :resource_timestamp, :datetime
    remove_column :service_credentials, :resource_timestamps, :jsonb
    remove_column :service_credentials, :resource_timestamps_max, :datetime

    remove_column :service_instance_nodes, :resource_timestamp, :datetime
    remove_column :service_instance_nodes, :resource_timestamps, :jsonb
    remove_column :service_instance_nodes, :resource_timestamps_max, :datetime

    remove_column :service_instances, :resource_timestamp, :datetime
    remove_column :service_instances, :resource_timestamps, :jsonb
    remove_column :service_instances, :resource_timestamps_max, :datetime

    remove_column :service_inventories, :resource_timestamp, :datetime
    remove_column :service_inventories, :resource_timestamps, :jsonb
    remove_column :service_inventories, :resource_timestamps_max, :datetime

    remove_column :service_offering_nodes, :resource_timestamp, :datetime
    remove_column :service_offering_nodes, :resource_timestamps, :jsonb
    remove_column :service_offering_nodes, :resource_timestamps_max, :datetime

    remove_column :service_offerings, :resource_timestamp, :datetime
    remove_column :service_offerings, :resource_timestamps, :jsonb
    remove_column :service_offerings, :resource_timestamps_max, :datetime

    remove_column :service_plans, :resource_timestamp, :datetime
    remove_column :service_plans, :resource_timestamps, :jsonb
    remove_column :service_plans, :resource_timestamps_max, :datetime
  end
end
