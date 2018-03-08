module ApplicationHelper
  def artists_to_text(artists)
    return '[unknown]' unless artists
    
    artists.map do |artist|
      if artist['uri']
        link_to(h(artist['name']), controller: 'browse', action: 'artist', id: artist['uri'])
      else
        h(artist['name'])
      end
    end.join(', ').html_safe
  end
  
  def album_link(album)
    if album['uri']
      link_to(h(album['name']), controller: 'browse', action: 'album', id: album['uri']).html_safe
    else
      h(album['name']).html_safe
    end
  end
  
  def length_text(length)
    seconds = length / 1000
    sprintf('%d:%02d', seconds / 60, seconds % 60)
  end
  
  def user_display_name(user)
    return '[unknown]' unless user
    user.name || user.email
  end
end
