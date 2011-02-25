var sys = require("sys");
var Connection = require("./connection");
var Client     = require("./client");
var redis      = require("./redis");
var redisClient = redis.createClient();

Connection.include({
  init: function(stream){
    this.stream     = stream;
    this.session_id = this.stream.sessionId;
    this.client     = new Client(this);

    this.stream.on("message", this.proxy(this.onmessage));
    this.stream.on("disconnect", this.proxy(this.ondisconnect));
  },
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

          if (message.data && message.data.auth_token && message.data.login) {
            var token = message.data.auth_token;
            var login = message.data.login;

            redisClient.get("teambox/users/" + token, function(err, login) {

              if (err) {
                console.log("[AuthenticatedConnection] Not authenticated: " + token);
              }
              else {
                console.log("[AuthenticatedConnection] Authenticated for: " + login);
                redisClient.sadd("teambox/users/online", login, function(err) {
                  if (err) {
                    console.log("[AuthenticatedConnection] Unable to mark user as online for: " + login); 
                  }
                  else {
                    console.log("[AuthenticatedConnection] Marked user as online for: " + login); 
                  }
                });
              }
            });
          }

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
  },
  ondisconnect: function(){
    var token = this.client.meta && this.client.meta.auth_token;
    var login = this.client.meta && this.client.meta.login;

    this.client.disconnect();

    //Mark as offline in redis
    if (login && token) {
      redisClient.get("teambox/users/" + token, function(err, login) {

        if (err) {
          console.log("[AuthenticatedConnection] Not authenticated: " + token);
        }
        else {
          console.log("[AuthenticatedConnection] Authenticated for: " + login);
          redisClient.srem("teambox/users/online", login, function(err) {
            if (err) {
              console.log("[AuthenticatedConnection] Unable to mark user as offline for: " + login); 
            }
            else {
              console.log("[AuthenticatedConnection] Marked user as offline for: " + login); 
            }
          });
        }
      });
    }
  }
});

module.exports = Connection;
