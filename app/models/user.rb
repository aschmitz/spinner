class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  has_many :library_tracks
  has_many :played_songs
  has_many :queue_entries
  
  PRESENCE_TIMEOUT = 5.minutes
end
