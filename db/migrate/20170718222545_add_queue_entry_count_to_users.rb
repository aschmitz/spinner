class AddQueueEntryCountToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :queue_entries_count, :integer, default: 0, nil: false
  end
end
