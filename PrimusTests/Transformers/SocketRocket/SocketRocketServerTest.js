var WebSocketServer = require('ws').Server;
var wss = new WebSocketServer({ port: 9999 });

wss.on('connection', function(ws) {
  console.log('[WebSocket] New connection.');

  ws.on('message', function(message) {
    console.log('[WebSocket] Received: %s.', message);

    console.log('[WebSocket] Echoing: %s.', message);

    ws.send(message);
  });
});

wss.on('listening', function() {
    console.log('\n[WebSocket] Server started.');
})
