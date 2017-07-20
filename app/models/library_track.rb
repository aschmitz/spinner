class LibraryTrack < ApplicationRecord
  belongs_to :user
  belongs_to :track
  
  validates_uniqueness_of :track, scope: :user_id
end
