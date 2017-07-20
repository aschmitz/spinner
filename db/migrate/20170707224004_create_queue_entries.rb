class CreateQueueEntries < ActiveRecord::Migration[5.1]
  def change
    create_table :queue_entries do |t|
      t.belongs_to :user
      t.belongs_to :track
      t.integer :sequence
      t.timestamps
    end
  end
end
