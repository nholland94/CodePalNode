socketio = require('socket.io')

count = 0

socketIOListen = (server) ->
  io = socketio.listen(server)

  io.sockets.on(
    'connection'
    (socket) ->
      console.log('recieved connection from: ', socket.id)
      console.log('there are a total of ' + count + ' users connected')
      count++

      socket.on(
        'disconnect'
        (data) ->
          count--
      )

      socket.on(
        'editorUpdate'
        (data) ->
          socket.broadcast.emit('editorUpdate', data)
      )

      socket.on(
        'requestEditorValues'
        (data) ->
          if count == 1
            socket.emit(
              'editorValues'
              'no_data'
            )
          else
            socket.broadcast.emit('requestEditorValues')
      )

      socket.on(
        'editorValues'
        (data) ->
          socket.broadcast.emit('editorValues')
      )
  )

exports.socketIOListen = socketIOListen
