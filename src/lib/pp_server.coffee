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

      setInterval(
        ->
          socket.emit('test', 'testing sockets')
        1000
      )
  )

exports.socketIOListen = socketIOListen
