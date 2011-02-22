var sys = require("sys");

var Events = require("./events");

var SuperClass = require("superclass");
Channel = module.exports = new SuperClass;

Channel.extend({
  channels: {},
  
  find: function(name){
    if ( !this.channels[name] ) 
      this.channels[name] = new Channel(name)
    return this.channels[name];
  },
  
  publish: function(message){
    var channels = message.getChannels();
    delete message.channels;
    
    sys.log(
      "Publishing to channels: " + 
      channels.join(", ") + " : " + message.data
    );
    
    for(var i=0, len = channels.length; i < len; i++) {
      message.channel = channels[i];
      var clients     = this.find(channels[i]).clients;
      
      for(var x=0, len2 = clients.length; x < len2; x++) {
        clients[x].write(message);
      }
    }
  },
  
  unsubscribe: function(client){
    for (var name in this.channels)
      this.channels[name].unsubscribe(client);
  }
});

Channel.include({
  init: function(name){
    this.name    = name;
    this.clients = [];
  },
  
  subscribe: function(client){
    this.clients.push(client);
    Events.subscribe(this, client);
  },
  
  unsubscribe: function(client){
    if ( !this.clients.include(client) ) return;
    this.clients = this.clients.delete(client);
    Events.unsubscribe(this, client);
  }
});
