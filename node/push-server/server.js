
/**
 * Module dependencies.
 */

var cluster = require('cluster'),
    connect = require('connect'),
    io = require('socket.io'),
    RedisStore = require('connect-redis'),
    buffer = [],
    http = require('http');

// setup:
//   $ npm install connect
        //sessions({
          //secret: '0b01c839aef4843c516781156f07a912358690de9a83090425f793786ae8821cb8f3448cc066b9286a12f779a794c603e5d3649e9dff50d4ed460894ef83b608',
          //session_key: '_teambox-2_session'
        //})

    var server = connect.createServer(
        connect.cookieDecoder(),
        connect.session({ store: new RedisStore({ maxAge: 60*60*24*30 }) }),
    );

server.use(function(req, res, next){
  var body = 'Hello World';
  res.writeHead(200, { 'Content-Length': body.length });
  res.end(body);
});

var socket = io.listen(server);
socket.on('connection', socket.prefixWithMiddleware( function (client, req, res) {
  client.send(JSON.stringify({ buffer: buffer }));
  client.broadcast(JSON.stringify({ announcement: client.sessionId + ' connected' }));

  client.on('message', function(message){
    var msg = { message: [client.sessionId, message] };
    buffer.push(msg);
    if (buffer.length > 15) buffer.shift();
    client.broadcast(JSON.stringify(msg));
  });

  client.on('disconnect', function(){
    client.broadcast(JSON.stringify({ announcement: client.sessionId + ' disconnected' }));
  });
}));


cluster(server)
  .set('workers', 2)
  .use(cluster.logger('logs'))
  .use(cluster.debug())
  .use(cluster.stats())
  .use(cluster.pidfiles('pids'))
  .use(cluster.cli())
  .use(cluster.repl(8888))
  .listen(8000);

