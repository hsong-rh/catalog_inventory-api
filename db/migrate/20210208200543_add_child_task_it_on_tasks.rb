class AddChildTaskItOnTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :child_task_id, :string
    add_column :sources, :refresh_task_id, :string
    add_column :sources, :last_refresh_message, :string
  end
end
