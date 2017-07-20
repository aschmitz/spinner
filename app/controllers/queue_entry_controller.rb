class QueueEntryController < ApplicationController
  before_action :load_and_authorize, only: [:destroy, :show, :update]
  
  def index
    @queue_entries = QueueEntry.where(user: current_user)
  end
  
  def destroy
    @queue_entry.destroy
  end
  
  private
  
  def load_and_authorize
    @queue_entry = QueueEntry.find(params[:id])
    raise 'No such queue entry' unless @queue_entry
    
    raise 'Not your queue entry' unless @queue_entry.user == current_user
  end
end
