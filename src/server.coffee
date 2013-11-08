# require('better-require')()
http = require('http')
fs = require('fs')

server = http.createServer (req, res) ->
  res.writeHead(200)
  res.end('Hello World')

server.listen(process.env.PORT || 8080)

socketIOListen = require('./lib/pp_server.js').socketIOListen

socketIOListen(server)
