class QueueEntryController < ApplicationController
  before_action :load_and_authorize, only: [:destroy, :show, :update]

  def index
    @queue_entries = QueueEntry.where(user: current_user)
  end

  def destroy
    @queue_entry.destroy
  end

  def create
    if (uri = params[:uri])
      #Allow for uri[] syntax in the query string to queue a list of tracks
      if (uri.is_a? Array)
        uri.each do |track_uri|
          track = Track.from_uri(track_uri)
          queue_track(track)
        end
        render plain: "ok queued #{uri.length}"
        return #I don't like that this return has to be here, but its nice to print the count back?
      #Otherwise we do the classic single song queue
      else
        track = Track.from_uri(uri)
        queue_track(track)
      end
      render plain: 'ok'
    elsif (album_uri = params[:album_uri])
      tracks = MopidyClient.instance.invoke('core.library.lookup', { uris: [album_uri] })
      tracks = tracks.values.first
      tracks.each do |track_tl|
        track = Track.from_uri(track_tl['uri'])
        queue_track(track)
      end
      render plain: 'okay'
    else
      render plain: "Couldn't figure out what you intended."
    end
  end

  private

  def load_and_authorize
    @queue_entry = QueueEntry.find(params[:id])
    raise 'No such queue entry' unless @queue_entry

    raise 'Not your queue entry' unless @queue_entry.user == current_user
  end

  def queue_track(track)
    # Add this to the user's library if it didn't already exist there
    LibraryTrack.where(user: current_user, track: track).first_or_create

    # Add this to the user's queue
    QueueEntry.create(user: current_user, track: track)
  end
end
