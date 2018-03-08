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
    render plain: 'No album' unless uri
    prefix_uri = uri.gsub(/^gmusic:album:([^B])/, 'gmusic:album:B\\1') # Fix for Google Play URI issue
    @tracks = MopidyClient.instance.invoke('core.library.lookup', [prefix_uri])
    @tracks = MopidyClient.instance.invoke('core.library.lookup', [uri]) if @tracks.empty?
    
    @album = @tracks.first['album']
  end
  
  def artist
    uri = params[:id]
    render plain: 'No artist' unless uri
    prefix_uri = uri.gsub(/^gmusic:artist:([^A])/, 'gmusic:artist:A\\1') # Fix for Google Play URI issue
    @albums = MopidyClient.instance.invoke('core.library.browse', [prefix_uri])
    @albums = MopidyClient.instance.invoke('core.library.browse', [uri]) if @albums.empty?
  end
end
