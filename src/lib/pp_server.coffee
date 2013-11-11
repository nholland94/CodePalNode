socketio = require('socket.io')

count = 0

htmlEditorOwner = null
cssEditorOwner = null

editors = {
  html: []
  css:  []
}

tracker = new Tracker("")

socketIOListen = (server) ->
  io = socketio.listen(server)

  io.sockets.on(
    'connection'
    (socket) ->
      console.log('recieved connection from: ', socket.id)
      count++
      console.log('there are a total of ' + count + ' users connected')

      socket.on(
        'disconnect'
        (data) ->
          console.log('user disconnected')
          count--
      )

      socket.on(
        'editorUpdate'
        (data) ->
          socket.broadcast.emit(
            'editorUpdate'
            {
              content: tracker.mergeState(data.version, data.content)
              version: tracker.version
              editor: data.editor
            }
          )
          # socket.broadcast.emit('editorUpdate', data)
      )

      socket.on(
        'editorValues'
        (data) ->
          socket.broadcast.emit('editorValues', data)
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
        'takeControl'
        (data) ->
          editorOwner = if data.editor == "html" then htmlEditorOwner else cssEditorOwner
          if editorOwner != null
            editorOwner.emit('removeControl', data)
          socket.emit('giveControl', data)

          # editerOwner = socket ? in js, will this reassign the variable or memory data?
          # It shares a pointer, but is the pointer reset? 

          if data.editor == "html"
            htmlEditorOwner = socket
          else
            cssEditorOwner = socket
      )
  )

exports.socketIOListen = socketIOListen
