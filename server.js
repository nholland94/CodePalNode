// Generated by CoffeeScript 1.6.3
(function() {
  var http, server, socketIOListen;

  require('better-require')();

  http = require('http');

  server = http.createServer(function(req, res) {
    res.writeHead(200);
    return res.end('Hello World');
  });

  server.listen(8080);

  socketIOListen = require('./lib/pp_server.coffee').socketIOListen;

  socketIOListen(server);

}).call(this);
