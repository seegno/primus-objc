var debug = require('debug')('socket.io');
var io = require('socket.io').listen(9999, { log: false });

io.set('destroy upgrade', false);

io.sockets.on('connection', function (socket) {
  debug('New connection.');

  socket.on('message', function (message) {
    debug('Echoing: %s.', message);

    socket.send(message);
  });
});

io.sockets.on('error', function (err) {
    console.log('Receive error:', err);
});

console.log('Server started.');
