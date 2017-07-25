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
end
