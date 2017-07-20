class HomeController < ApplicationController
  def ping
    render plain: ''
  end
  
  def nowplaying
    render partial: 'nowplaying'
  end
  
  def queue
    render partial: 'queue'
  end
end
