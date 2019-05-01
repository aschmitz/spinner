let App =  require('../cable');

App.room = App.cable.subscriptions.create('RoomChannel', {
  connected: function() {},
  disconnected: function() {},
  received: function(msg) {
    if (!msg.hasOwnProperty('event')) { return; }
    
    switch (msg.event) {
      case 'nowplaying_change':
        // This does nothing if #now_playing isn't on the page, which is nice.
        $('#now_playing').load('/home/nowplaying');
        break;
      default:
        console.log('Unknown event from room:', msg);
    }
  },
});
