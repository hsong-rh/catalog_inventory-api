class AddAvailabilityCheckMessageToSources < ActiveRecord::Migration[5.2]
  def change
    add_column :sources, :availability_message, :string
  end
end
