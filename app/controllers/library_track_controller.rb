class LibraryTrackController < ApplicationController
  def index
    @library_tracks = LibraryTrack.where(user: current_user).includes(:track)
  end
end
