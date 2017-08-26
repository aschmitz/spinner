class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  has_many :library_tracks
  has_many :played_songs
  has_many :queue_entries
  has_many :ratings
  
  after_save :fix_next_track, if: -> { saved_change_to_attribute?(:in_room) }
  
  PRESENCE_TIMEOUT = 5.minutes
  
  protected
  def fix_next_track
    QueueEntry.fix_next!
  end
end
