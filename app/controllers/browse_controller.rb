class BrowseController < ApplicationController
  def search
    query = params[:q]
    
    render plain: 'No query' unless query
    
    batches = MopidyClient.instance.invoke('core.library.search', [
      {'any' => query},
      ['gmusic:directory']
    ])
    
    @artists = []
    @albums = []
    @tracks = []
    batches.each do |batch|
      @artists += batch['artists'].to_a
      @albums += batch['albums'].to_a
      @tracks += batch['tracks'].to_a
    end
  end
  
  def album
    uri = params[:id]
    uri.gsub!(/^gmusic:album:([^B])/, 'gmusic:album:B\\1') # Fix for Google Play URI issue
    render plain: 'No album' unless uri
    
    @tracks = MopidyClient.instance.invoke('core.library.lookup', [uri])
    @album = @tracks.first['album']
    # render plain: @tracks.to_yaml
  end
  
  def artist
    uri = params[:id]
    uri.gsub!(/^gmusic:artist:([^A])/, 'gmusic:artist:A\\1') # Fix for Google Play URI issue
    render plain: 'No artist' unless uri
    
    @albums = MopidyClient.instance.invoke('core.library.browse', [uri])
    # render plain: @res.to_yaml
  end
  
  def queue
    uri = params[:uri]
    render plain: 'No URI' unless uri
    
    track = Track.from_uri(uri)
    
    # Add this to the user's library if it didn't already exist there
    LibraryTrack.where(user: current_user, track: track).first_or_create
    
    # Add this to the user's queue
    QueueEntry.create(user: current_user, track: track)
    
    render plain: 'ok'
    
    # res = MopidyClient.instance.invoke('core.tracklist.add', [nil, nil, nil, [params[:uri]]])
    # if res.first['__model__'] == 'TlTrack'
    #   render plain: 'success'
    # else
    #   render plain: 'error'
    # end
  end
end
