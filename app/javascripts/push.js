if ( typeof( window['Teambox'] ) == "undefined" ) {
  window.Teambox = {};
}

if ( typeof( window.Teambox.User ) == "undefined" ) {
  Teambox.User = {};
}

Teambox.Notification = function(data, action) {
  this.data = data;
  this.action = action;
};

Teambox.Notification.prototype.notify = function(callback) {
  this.action();
  callback();
};

Teambox.NotificationsBuffer = function() {
  this.notifications = [];
};

Teambox.NotificationsBuffer.prototype.addNotification = function(notification) {
  if (this.notifications.length < 5) {
    this.notifications.push(notification);
  }
  else {
    this.flushAll(true);
  }
};

Teambox.NotificationsBuffer.prototype.flushAll = function(nonotify, scrollToId) {
  var flushBuffer = this.notifications.clone();
  this.notifications.clear();
  for (var i = 0; i < flushBuffer.length; i++) {
    var notification = flushBuffer.shift();
    if (!nonotify) {
      notification.notify(function() {
        //Do something
      });
    }
  };
};

Teambox.Notifications = new Teambox.NotificationsBuffer();

Teambox.ActivityNotifier = {
  notificationForComments: function(activity) {
    return new Teambox.Notification(activity, function() {
    });
  },
  notificationForThreads: function(activity) {
    return new Teambox.Notification(activity, function() {
    });
  },
  notificationForOthers: function(activity) {
    return new Teambox.Notification(activity, function() {
    });
  },
  notifyActivity: function(activity) {
    var notification = false;

    if (activity.target_type === 'Comment') {
        notification = this.notificationForComments(activity);
    }
    else if (['Conversation', 'Task', 'TaskList'].indexOf(activity.target_type) > 0) {
        notification = this.notificationForThreads(activity);
    }
    else {
        notification = this.notificationForOthers(activity);
    }

    if (notification) {
      Teambox.Notifications.addNotification(notification);
    }
  }
};

document.on('click', '#show_new_content a', function(e) {
  e.preventDefault();

  var target = e.target,
      element_id = false;

  if (target) {
    element_id = target.readAttribute('data-activity-id');
  }

  Teambox.Notifications.flushAll(false, element_id);
});

Teambox.User.handleFocusEvent = function(e) {
  var event = e || window.event,
      target = event.target || event.srcElement;
  if (target && ['INPUT','TEXTAREA'].indexOf(target.tagName) != -1) {
    Teambox.User.currently_focussed_element = target;
  }
};

document.on('dom:loaded', function() {

  if (Teambox && Teambox.pushServer) {

    // IE
    document.onfocusin = Teambox.User.handleFocusEvent;
    document.onfocusout = Teambox.User.handleFocusEvent;

    if (document.addEventListener) {
      document.addEventListener('focus',Teambox.User.handleFocusEvent,true);
    }

    Teambox.pushServer.on('connect', function() {
      console.log("connected: ", this.socket.transport.sessionid);
    });

    Teambox.pushServer.on('disconnect', function() {
      console.log("disconnected: ");
    });


    if (window.my_user) {
      Teambox.pushServer.subscribe("/users/" + my_user.authentication_token, function(message){
        try {
          var activity = JSON.parse(message);
          console.log("Received activity: ", activity);
          if (activity.target_type == 'Person' || activity.user_id != my_user.id) {
            if ([/^\/$/,/^\/projects\/?$/, /^\/projects\/[^\/]+\/?$/, /#!\/projects\/[^\/]+\/?$/].any(function(r){ return (r.exec(window.location.hash) || r.exec(window.location.pathname) || []).length > 0})) {

              var project_level_matches = /#!\/projects\/([^\/]+)\/?$/.exec(window.location.hash) || /^\/projects\/([^\/]+)\/?$/.exec(window.location.pathname);

              if (project_level_matches && (project_level_matches[1] === activity.project.permalink)) {
                Teambox.ActivityNotifier.notifyActivity(activity);
              }
              else if (!project_level_matches) {
                Teambox.ActivityNotifier.notifyActivity(activity);
              }
            }
          }
        }
        catch(err) {
          console.log('[Push Error]'  + err + ' parsing: ', message);
        }
      });
    }
  }
});

