document.on('dom:loaded', function() {

  Teambox.pushServer.on('connect', function() {
    console.log("connected: ", this.socket.transport.sessionid);
  });

  Teambox.pushServer.on('disconnect', function() {
    console.log("disconnected: ");
  });


  if (window.my_projects) {
    var projects = $H(window.my_projects);

    projects.each(function(e) {
      var project = e[1];
      Teambox.pushServer.subscribe("/projects/" + project.permalink, function(data){
        console.log("Got data: ", data);
      });
    });
  }
});

