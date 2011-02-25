document.on('dom:loaded', function() {

if ( typeof( window['Teambox'] ) == "undefined" ) {
  window.Teambox = {};
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

document.on('click','#header_icons li.notifications_icon a', function(e) {
  e.preventDefault();
  Teambox.Notifications.toggleNotificationWindow();
});

document.on('dom:loaded', function() {

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
        if (activity.user_id != my_user.id) {
          Teambox.ActivityNotifier.notifyActivity(activity);
        }
      }
      catch(err) {
        console.log('[Push Error]'  + err + ' parsing: ', message);
      }
    });
  }
});

