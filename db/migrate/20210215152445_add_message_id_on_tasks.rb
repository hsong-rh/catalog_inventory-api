class AddMessageIdOnTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :controller_message_id, :string
  end
end
