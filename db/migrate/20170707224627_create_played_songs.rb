class CreatePlayedSongs < ActiveRecord::Migration[5.1]
  def change
    create_table :played_songs do |t|
      t.belongs_to :track_id
      t.belongs_to :user
      t.datetime :played_at
      t.boolean :skipped
      t.timestamps
    end
  end
end
