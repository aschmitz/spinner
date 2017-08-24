class HomeController < ApplicationController
  def ping
    render plain: ''
  end
  
  def presence
    current_user.in_room = (params[:in_room] == 'true')
    current_user.save
    render plain: "You are now marked as #{current_user.in_room ? '' : 'not '}listening to music."
  end
  
  def nowplaying
    render partial: 'nowplaying'
  end
  
  def queue
    render partial: 'queue'
  end
  
  def skip_my_song
    # Really, we should check to see if this song is actually the one that's
    # playing, or that a song is playing at all, but we don't actually store
    # tlids once songs are actually played. If we did, we could check, but we
    # don't, so we can't meaningfully check. We'll probably rectify that
    # sometime.
    current_song = PlayedSong.order(played_at: :desc).first
    if current_song.user == current_user
      current_song.skipped = true
      current_song.save
      MopidyClient.instance.invoke('core.playback.next')
      render plain: "sorry you didn't like it"
    else
      render plain: "that's not your song"
    end
  end
end
