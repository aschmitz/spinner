class AddTlids < ActiveRecord::Migration[5.1]
  def change
    add_column :played_songs, :tlid, :integer
    add_column :queue_entries, :tlid, :integer
  end
end
