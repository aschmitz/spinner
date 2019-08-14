class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :track
  
  validates :score, inclusion: { in: [-1, 0, 1] }
  
  SCORE_TO_TEXT = {
    -1 => '🙁',
    0 => '😐',
    1 => '🙂',
  }.freeze
end
