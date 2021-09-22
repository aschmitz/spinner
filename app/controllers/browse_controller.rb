class BrowseController < ApplicationController
  def search
    query = params[:q]

    render plain: 'No query' unless query

    batches = MopidyClient.instance.invoke(
      'core.library.search',
      {
        query: { any: [query] },
        uris: ['spotify:'],
        exact: false,
      }
    )

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
    @tracks = MopidyClient.instance.invoke('core.library.lookup', { uris: [uri] })
    @tracks = @tracks.values.first

    @album = @tracks.first['album']
  end

  def top_tracks
    uri = params[:id]
    render plain: 'No top tracks uri' unless uri
    @artist = MopidyClient.instance.invoke('core.library.lookup', { uri: [uri] })

    @tracks = []
    @all_tracks_uri = []
    top_tracks = MopidyClient.instance.invoke('core.library.browse', { uri: uri })
    top_tracks.each do |track|
      # We may be able to just lookup all at once instead of making a ton of RPC calls?
      @tracks += MopidyClient.instance.invoke('core.library.lookup', { uris: [track['uri']] })
      @all_tracks_uri.push(track['uri'])
    end
  end

  def artist
    uri = params[:id]
    render plain: 'No artist' unless uri
    @albums = MopidyClient.instance.invoke('core.library.browse', { uri: uri })
    # Split the top tracks entry out
    @albums.each do |album|
      if album['uri'].ends_with?(":top")
        @top_tracks = album
      end
    end
    @albums = @albums - [@top_tracks]
  end
end
