class CreateTracks < ActiveRecord::Migration[5.1]
  def change
    create_table :tracks do |t|
      t.string :title
      t.integer :length
      t.string :uri
      t.text :details
      t.integer :volume, default: 50
      t.timestamps
    end
    
    add_index :tracks, :uri, unique: true
  end
end
