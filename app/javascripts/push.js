document.on('dom:loaded', function() {

  Teambox.pushServer.on('connect', function() {
    console.log("connected: ", this.socket.transport.sessionid);
  });

  Teambox.pushServer.on('disconnect', function() {
    console.log("disconnected: ");
  });


  if (window.my_user) {
    Teambox.pushServer.subscribe("/users/" + my_user.authentication_token, function(data){
      console.log("Got data: ", data);
    });
  }
});

