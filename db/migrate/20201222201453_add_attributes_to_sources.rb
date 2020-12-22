class AddAttributesToSources < ActiveRecord::Migration[5.2]
  def change
    add_column :sources, :availability_status, :string
    add_column :sources, :last_checked_at, :datetime
    add_column :sources, :last_available_at, :datetime
  end
end
