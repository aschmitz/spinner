App.queue = App.cable.subscriptions.create('QueueChannel', {
  connected: function() {},
  disconnected: function() {},
  received: function(msg) {
    if (!msg.hasOwnProperty('event')) { return; }
    
    switch (msg.event) {
      case 'change':
        // This does nothing if #your_queue isn't on the page, which is nice.
        $('#your_queue').load('/home/queue');
        break;
      default:
        console.log('Unknown event from queue:', msg);
    }
  },
});
