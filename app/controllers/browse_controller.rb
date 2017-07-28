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
  end
  
  def artist
    uri = params[:id]
    uri.gsub!(/^gmusic:artist:([^A])/, 'gmusic:artist:A\\1') # Fix for Google Play URI issue
    render plain: 'No artist' unless uri
    
    @albums = MopidyClient.instance.invoke('core.library.browse', [uri])
  end
end
