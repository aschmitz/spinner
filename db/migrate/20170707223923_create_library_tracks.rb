class CreateLibraryTracks < ActiveRecord::Migration[5.1]
  def change
    create_table :library_tracks do |t|
      t.belongs_to :user
      t.belongs_to :track
      t.timestamps
    end
  end
end
