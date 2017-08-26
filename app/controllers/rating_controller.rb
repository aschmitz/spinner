class RatingController < ApplicationController
  MOUTH = {
    -1 => '(',
    0 => '|',
    1 => ')',
  }
  
  def create
    track = Track.find(params[:track_id])
    score = params[:score].to_i
    
    # Yes, this isn't really RESTful, but it makes for a much easier API.
    if (rating = Rating.find_by(user: current_user, track: track))
      rating.score = score
    else
      rating = Rating.new(user: current_user, track: track, score: score)
    end
    
    unless rating.save
      render plain: "Errors: #{rating.errors}"
      return
    end
    
    render plain: "Saved. :#{MOUTH[score]}"
  end
  
  def destroy
    rating = Rating.find(params[:id])
    
    if rating.user == current_user
      rating.destroy
      render plain: 'All is forgotten.'
    else
      render plain: "That's just not you."
    end
  end
end
