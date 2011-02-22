# Juggernaut

Juggernaut lets you push data to browser, which means you can do awesome 
things like multiplayer gaming, chat, realtime collaboration and more!

Juggernaut is super simple and easy to get going. 
Juggernaut 2, which is a completely rewrite, is built on node.js, is insanely fast, and can scale horizontally to millions of clients.

## Features

* node.js server
* Ruby client
* Supports the following protocols:
  * WebSocket
  * Adobe Flash Socket
  * ActiveX HTMLFile (IE)
  * Server-Sent Events (Opera)
  * XHR with multipart encoding
  * XHR with long-polling
* Reconnection support 
* SSL support

## Subscribe (JavaScript)

    <script src="http://localhost:8080/application.js" type="text/javascript" charset="utf-8"></script>
    <script type="text/javascript" charset="utf-8">
      var jug = new Juggernaut;
      jug.subscribe("channel_name", function(data){
        console.log("Got data: " + data);
      });
    </script>

## Publish (Ruby)

    Juggernaut.publish("channel_name", {:some => "data"})
    Juggernaut.publish(["channel1", "channel2"], "foo")

## Requirements

* Node.js
* Redis
* Ruby
 
## Setup

###Install [Node.js](http://nodejs.org)

    wget http://nodejs.org/dist/node-v0.2.4.tar.gz
    tar -xzvf node-v0.2.4.tar.gz
    cd node-v0.2.4
    ./configure
    make
    sudo make install

###Install [Redis](http://code.google.com/p/redis)

    wget http://redis.googlecode.com/files/redis-2.0.3.tar.gz
    tar -xzvf redis-2.0.3.tar.gz
    cd redis-2.0.3
    make

###Install the [Juggernaut](http://rubygems.org/gems/juggernaut) gem (optional)

    gem install juggernaut

##Running

Start Redis

    cd redis-2.0.3
    ./redis-server redis.conf

Download Juggernaut, and start the Juggernaut server:

    git clone git://github.com/maccman/juggernaut.git --recursive
    cd juggernaut
    node server.js

That's it! Now go to [http://localhost:8080](http://localhost:8080) to see Juggernaut in action.

## Flash

Flash is optional, but it's the default fallback for Firefox (until the beta is released).
Start the server using root if you want Flash support. It needs to open a restricted port.
Also, you need to specify the location of WebSocketMain.swf

Either copy it to your web app root, or set the address like this:

    window.WEB_SOCKET_SWF_LOCATION = "http://juggaddress:8080/WebSocketMain.swf"
  
## SSL

Juggernaut has SSL support! To activate, just put create a folder called 'keys' in the 'juggernaut' dir, 
containing your privatekey.pem and certificate.pem files. 

    >> mkdir keys
    >> cd keys
    >> openssl genrsa -out privatekey.pem 1024 
    >> openssl req -new -key privatekey.pem -out certrequest.csr 
    >> openssl x509 -req -in certrequest.csr -signkey privatekey.pem -out certificate.pem

Then, pass the secure option to Juggernaut:
  
    var juggernaut = new Juggernaut({secure: true})

## Daemonize

[http://kevin.vanzonneveld.net/techblog/article/run_nodejs_as_a_service_on_ubuntu_karmic](http://kevin.vanzonneveld.net/techblog/article/run_nodejs_as_a_service_on_ubuntu_karmic)

# Scaling

Just create more Juggernaut daemons. Put a TCP load balancer in front of them.
Make sure they all connect to the same Redis instance. Use sticky sessions.

## Usage case - Group Chat

    <script src="http://localhost:8080/application.js" type="text/javascript" charset="utf-8"></script>
    <script type="text/javascript" charset="utf-8">
      var jug = new Juggernaut;
      jug.subscribe("/chats", function(data){
        var li = $("<li />");
        li.text(data);
        $("#chats").append(li);
      });  
    </script>

    Juggernaut.publish("/chats", params[:body])

## Usage case - Private Chat

    <script src="http://localhost:8080/application.js" type="text/javascript" charset="utf-8"></script>
    <script type="text/javascript" charset="utf-8">
      var jug = new Juggernaut;
      jug.subscribe("/chats/<%= current_user.id %>", function(data){
        var li = $("<li />");
        li.text(data);
        $("#chats").append(li);
      });  
    </script>

    Juggernaut.publish(users.map {|u| "/chats/#{u.id}" }, params[:body])

## Usage case - Model Synchronisation 

### Implement sync_clients on models

    def sync_clients
      users.map(&:id)
    end
  
Check out client/examples/juggernaut_observer.rb and client/examples/juggernaut_observer.js
