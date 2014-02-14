var io = require('socket.io').listen(9999);

io.set('destroy upgrade', false);

io.sockets.on('connection', function (socket) {
  console.log('[SocketIO] New connection.');

  socket.on('message', function (message) {
    console.log('[SocketIO] Received: %s.', message);

    console.log('[SocketIO] Echoing: %s.', message);

    socket.send(message);
  });
});

console.log('\n[SocketIO] Server started.');
