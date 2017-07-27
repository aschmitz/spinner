class QueueEntry < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :track
  before_create :set_sequence
  after_save :notify_user_of_queue_change
  after_destroy :notify_user_of_queue_change
  
  def self.next_up
    # We want to find queue entries for users who have defined themselves as
    # being in the room, and have been present recently.
    applicable_users = User.where(in_room: true)
      .where('last_present > ?', User::PRESENCE_TIMEOUT.ago)
      .where('queue_entries_count > 0')
      .order(id: :asc)
    
    # We currently just rotate in user ID order.
    last_song = PlayedSong.order(created_at: :desc).first
    last_uid = last_song ? last_song.user_id : 0
    
    # Find the next user up. If there's none with a UID higher than the last
    # player, wrap around.
    user = applicable_users.where('id > ?', last_uid).first || applicable_users.first
    
    return nil unless user
    
    user.queue_entries.order(sequence: :asc).first
  end
  
  def add_to_mopidy!
    # Might we already be queued?
    if self.tlid
      # If we're already in the tracklist, just return.
      return self.tlid if MopidyClient.instance.invoke('core.tracklist.index', [nil, self.tlid])
    end
    
    res = MopidyClient.instance.invoke('core.tracklist.add', [nil, nil, nil, [self.track.uri]]).first
    unless res['__model__'] == 'TlTrack'
      raise 'Unexpected response type: '+res['__model__']
    end
    
    self.tlid = res['tlid']
    save
    
    self.tlid
  end
  
  def remove_from_mopidy!
    return false unless self.tlid
    
    res = MopidyClient.instance.invoke('core.tracklist.remove', [{tlid: [self.tlid]}]).first
    unless res['__model__'] == 'TlTrack'
      raise 'Unexpected response type: '+res['__model__']
    end
    
    self.tlid = nil
    save
    
    true
  end
  
  # This destructively turns this queue entry into a PlayedSong record.
  def turn_into_played_song!
    ps = PlayedSong.create(
      track: self.track,
      user: self.user,
      played_at: Time.now,
      skipped: false,
      tlid: self.tlid,
    )
    
    self.destroy
    
    ps
  end
  
  protected
  def set_sequence
    self.sequence = (QueueEntry.where(user: user).maximum(:sequence) || 0) + 1
  end
  
  def notify_user_of_queue_change
    ActionCable.server.broadcast("queue_channel_#{user.id}", {
      event: 'change',
    })
  end
end
