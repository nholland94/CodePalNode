socketio = require('socket.io')
Tracker = require('./reversion.js').Tracker

count = 0

htmlEditorOwner = null
cssEditorOwner = null

editors = {
  html: []
  css:  []
}

tracker = new Tracker("")

versions = {}

socketIOListen = (server) ->
  io = socketio.listen(server)

  io.set('log level', 1)

  io.sockets.on(
    'connection'
    (socket) ->
      console.log('recieved connection from: ', socket.id)
      count++
      console.log('there are a total of ' + count + ' users connected')

      versions[socket.id] = -1

      socket.on(
        'disconnect'
        (data) ->
          console.log('user disconnected')
          count--
      )

      socket.on(
        'editorUpdate'
        (data) ->
          broadcastData = {
            contents: tracker.mergeState(
              if versions[socket.id] > data.version then versions[socket.id] else data.version
              data.contents)
            version: tracker.version
            editor: data.editor
          }

          socket.broadcast.emit(
            'editorUpdate'
            broadcastData
          )

          console.log('current text: ', tracker.getValue())

          versions[socket.id] = broadcastData.version

          socket.emit(
            'updateVersion'
            tracker.version
          )
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
