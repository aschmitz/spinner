class AddRoomPropertiesToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :last_present, :datetime, default: nil
    add_column :users, :in_room, :boolean, default: false, nil: false
  end
end
