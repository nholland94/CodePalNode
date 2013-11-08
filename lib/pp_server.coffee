socketio = require('socket.io')

socketIOListen = (server) ->
  io = socketio.listen(server)

  io.sockets.on(
    'connection'
    (socket) ->
      console.log('recieved connection from: ', sockect.id)
  )

exports.socketIOListen = socketIOListen
