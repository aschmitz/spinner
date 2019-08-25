let App =  require('../cable');

function notifySongChange(track){
  if(Notification.permission != "granted"){
    Notification.requestPermission();
  }
  if(Notification.permission == "granted"){
    let notification = new Notification("Now Playing", {
      body:  `${track.title} - ${track.details.album.name}`,
      tag: track.uri,
      icon: track.details.album.images[0],
    });
  }
}

App.room = App.cable.subscriptions.create('RoomChannel', {
  connected: function() {},
  disconnected: function() {},
  received: function(msg) {
    if (!msg.hasOwnProperty('event')) { return; }
    
    switch (msg.event) {
      case 'nowplaying_change':
        // This does nothing if #now_playing isn't on the page, which is nice.
        $('#now_playing').load('/home/nowplaying');
        // But we still may want to see that a song changed:
        notifySongChange(JSON.parse(msg.track));
        break;
      default:
        console.log('Unknown event from room:', msg);
    }
  },
});
