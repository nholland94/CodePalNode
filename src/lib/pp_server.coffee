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

      socket.on(
        'requestEditorValues'
        (data) ->
          socket.broadcast.emit('requestEditorValues')
      )

      socket.on(
        'editorValues'
        (data) ->
          socket.broadcast.emit('editorValues')
      )
  )

exports.socketIOListen = socketIOListen
