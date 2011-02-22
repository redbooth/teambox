require("./ext/array");

var Publish = require("./publish");
var Server  = require("./server");

module.exports.listen = function(port){
  Publish.listen();
  var server = new Server;
  server.listen(port);
};