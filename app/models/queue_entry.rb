class QueueEntry < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :track
  before_create :set_sequence
  after_save :notify_user_of_queue_change
  after_destroy :notify_user_of_queue_change
  after_destroy :remove_and_update_queue
  
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
  
  def self.fix_next!
    # Do we have any queue entries that we have queued? There should be at most
    # one.
    queued = QueueEntry.where.not(tlid: nil)
    if queued.count > 1
      # Just unqueue them all and sort it out in a moment.
      queued.map(&:remove_from_mopidy!)
      queued = nil
    else
      queued = queued.first # Works even if it returns nil
    end
    
    # What *should* the next track be?
    next_queue_entry = self.next_up
    
    # Abort if we're all good
    return if queued == next_queue_entry
    
    # Otherwise, we need to swap in the next song.
    # However! Mopidy doesn't take kindly to deleting a song that's currently
    # playing, and this turns out to be a bit of a race condition, so we solve
    # that by doing the following:
    # 
    # 1. Queue the "real" next song (if any).
    # 2. Check to see if the wrong song (`queued`) is currently playing.
    # 2a. If so, play the next song.
    # 3. Delete the wrong song from the queue.
    # 
    # (Thanks to Surinna for coming up with this procedure.)
    
    # So then:
    # 1. Queue the "real" next song (if any).
    next_queue_entry.add_to_mopidy! if next_queue_entry
    
    # 2. Check to see if the wrong song (`queued`) is currently playing.
    if queued
      current_tlid = MopidyClient.instance.invoke('core.tracklist.index')
      if queued.tlid == current_tlid
        # 2a. If so, play the next song.
        MopidyClient.instance.invoke('core.playback.next')
      end
      
      # 3. Delete the wrong song from the queue.
      queued.remove_from_mopidy!
    end
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
    # If there was an error, the track probably wasn't in the list anyway.
    
    self.tlid = nil
    save
    
    true
  end
  
  # This destructively turns this queue entry into a PlayedSong record.
  def turn_into_played_song!
    return false unless self.tlid
    
    ps = PlayedSong.create(
      track: self.track,
      user: self.user,
      played_at: Time.now,
      skipped: false,
      tlid: self.tlid,
    )
    
    # This prevents us from removing this track from Mopidy when we go to
    # remove queued-then-deleted tracks from Mopidy. Even so, we don't do this
    # if we're already in the middle of destroying this QueueEntry.
    unless destroyed?
      self.tlid = nil
      self.save
      
      self.destroy
    end
    
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
  
  def remove_and_update_queue
    self.remove_from_mopidy!
    QueueEntry.fix_next!
  end
end
