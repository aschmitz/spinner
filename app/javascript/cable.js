ActionCable = require('actioncable');

let App = {};

App.cable = ActionCable.createConsumer();

module.exports = App;