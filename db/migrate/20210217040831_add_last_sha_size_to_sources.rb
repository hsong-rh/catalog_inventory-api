class AddLastShaSizeToSources < ActiveRecord::Migration[5.2]
  def change
    add_column :sources, :previous_sha, :string
    add_column :sources, :previous_size, :integer
  end
end
