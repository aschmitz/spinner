class FixPlayedSongsTrackColumn < ActiveRecord::Migration[5.1]
  def change
    rename_column :played_songs, :track_id_id, :track_id
  end
end
