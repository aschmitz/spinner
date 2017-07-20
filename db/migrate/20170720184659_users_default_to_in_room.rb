class UsersDefaultToInRoom < ActiveRecord::Migration[5.1]
  def change
    change_column_default :users, :in_room, true
  end
end
