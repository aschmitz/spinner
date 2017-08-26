class CreateRatings < ActiveRecord::Migration[5.1]
  def change
    create_table :ratings do |t|
      t.belongs_to :track
      t.belongs_to :user
      t.integer :score
      t.timestamps
      t.index(:track_id)
      t.index(:user_id)
      t.index([:track_id, :user_id], unique: true)
    end
  end
end
