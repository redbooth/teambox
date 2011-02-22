var sys = require("sys");
var Connection = require("./connection");
var redis      = require("./redis");
var redisClient = redis.createClient();

Connection.include({
  onmessage: function(data){
    console.log("[AuthenticatedConnection] Received: " + data);

    try {
      var message = Message.fromJSON(data);

      switch (message.type){
        case "subscribe":
          var channel = message.getChannel();
          var client = this.client;

          var token = (/\/users\/(.*)$/.exec(channel) || [false,false])[1];
          redisClient.get("teambox/users/" + token, function(err, login) {

            if (err) {
              console.log("[AuthenticatedConnection] Not authenticated for channel: " + channel);
            }
            else {
              console.log("[AuthenticatedConnection] Authenticated for channel: /users/" + login);
              client.subscribe(channel);
            }
          });
        break;
        case "unsubscribe":
          this.client.unsubscribe(message.getChannel());
        break;
        case "meta":
          this.client.setMeta(message.data);
          var client = this.client;

          //if (message.data && message.data.teambox_session_id) {
            //var sessionId = message.data.teambox_session_id;

            //console.log("[AuthenticatedConnection] Got teambox session id: " + sessionId);
            //console.log("[AuthenticatedConnection] Get redis key: " + "_teambox-2_session_:" + sessionId);

            //redisClient.get("_teambox-2_session_:" + sessionId, function(err, value) {
              //console.log("[AuthenticatedConnection] got value from redis...");
              //if (err) {
                //console.log("[AuthenticatedConnection] Unable to connect to redis or no teambox session. Disconnecting!...");
                //client.disconnect();
              //}
              //else {
                //console.log("[AuthenticatedConnection] Got teambox session from redis: " + value);

                //var session = (/JSONHash\w?(.*)$/.exec(value) || [false,false])[1];
                //if (session) {
                  //try {
                    //console.log("[AuthenticatedConnection] Parsed teambox session from marshal dump: " + session);
                    //session = JSON.parse(session);
                    //console.log(session);

                    //if (!session['user_id']) {
                      //console.log("[AuthenticatedConnection] User not logged in. Disconnecting!...");
                      //client.disconnect();
                    //}
                    //else {
                      //console.log("[AuthenticatedConnection] User authenticated...");
                    //}
                  //}
                  //catch(e) {
                    //console.log("[AuthenticatedConnection] Error parsing teambox session!");
                    //console.log(e);
                    //client.disconnect();
                  //}
                //}
                //else {
                  //console.log("[AuthenticatedConnection] Unable to parse teambox session. Disconnecting!...");
                  //client.disconnect();
                //}
              //}
            //});
          //}
        break;
        case "event":
          this.client.event(message.data);
        break;
        default:
          throw "[AuthenticatedConnection] Unknown type"
      }
    } catch(e) { 
      sys.error("[AuthenticatedConnection] Error!");
      sys.error(e);
      return; 
    }
  }
});

module.exports = Connection;
