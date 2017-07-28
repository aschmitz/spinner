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
      track = Track.from_uri(uri)
      queue_track(track)
      
      render plain: 'ok'
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
