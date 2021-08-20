class Track < ApplicationRecord
  has_many :ratings
  
  store :details, coder: JSON
  validates :uri, uniqueness: true
  
  def self.from_uri(uri)
    where(uri: uri).first_or_create do |track|
      details = MopidyClient.instance.invoke('core.library.lookup', [[uri]])
      raise 'Could not find track' unless details.length == 1
      details = details.first
      
      track.details = details
      track.title = details['name']
      track.length = details['length']
    end
  end
  
  def image
    if self.details && self.details['album'] && self.details['album']['images']
      self.details['album']['images'].first
    else
      nil
    end
  end
end
