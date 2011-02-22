var sys     = require("sys");
var redis   = require("./redis");
var Message = require("./message");
var Channel = require("./channel");

Publish = module.exports = {};
Publish.listen = function(){
  this.client = redis.createClient();
  this.client.subscribeTo("juggernaut", function(_, data) {
    sys.log("Received: " + data);
    
    try {
      var message = Message.fromJSON(data);
      sys.log('Got message: ' + message);
      if (message.type === 'meta' && message.data && message.data.teambox_session_id) {
        var sessionId = message.data.teambox_session_id;
        sys.log('Got session id: ' + sessionId);
      }
    } catch(e) { return; }
    
    Channel.publish(message);
  });
};
