var debug = require('debug')('websocket');
var WebSocketServer = require('ws').Server;

var wss = new WebSocketServer({ port: 9999 });

wss.on('connection', function(ws) {
  debug('New connection.');

  ws.on('message', function(message) {
    debug('Echoing: %s.', message);

    ws.send(message);
  });
});

wss.on('error', function (err) {
    console.log('Receive error:', err);
});

wss.on('listening', function() {
  console.log('Server started.');
});
