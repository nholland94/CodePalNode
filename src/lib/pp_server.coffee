socketio = require('socket.io')

socketIOListen = (server) ->
  io = socketio.listen(server)

  io.sockets.on(
    'connection'
    (socket) ->
      console.log('recieved connection from: ', socket.id)

      socket.on(
        'editorUpdate'
        (data) ->
          socket.broadcast.emit('editorUpdate', data)
      )
  )

exports.socketIOListen = socketIOListen
