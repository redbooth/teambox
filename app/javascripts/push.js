if ( typeof( window['Teambox'] ) == "undefined" ) {
  window.Teambox = {};
}

Teambox.Notification = function(action) {
  this.action = action;
};

Teambox.Notification.prototype.notify = function() {
  this.action();
};

Teambox.NotificationsBuffer = function() {
  this.notifications = [];
};

Teambox.NotificationsBuffer.prototype.toggleNotificationsIcon = function() {
  if (this.notificationsIcon) {
    var icon = this.notificationsIcon;
    if (icon.getStyle('opacity') === 1) {
      icon.removeClassName('active');
    }
    else {
      icon.addClassName('active');
    }
  }
};

Teambox.NotificationsBuffer.prototype.toggleNotificationWindow = function(force) {
  if (this.notificationsWindow) {
    if (!this.notificationsWindow.visible()) {
      if (this.notifications.length === 0) {
        this.notificationsWindow.toggle();
        this.toggleNotificationsIcon();
        if (!force) {
          setTimeout(1000*10, function() {
            this.notificationsWindow.toggle();
          });
        }
      }
    }
    else {
      this.notificationsWindow.toggle();
    }
  }
};

//Add notification but flush if we reach 5 unread notifications
Teambox.NotificationsBuffer.prototype.addNotification = function(notification) {
  if (this.notifications.length < 5) {
    this.notifications.push(notification);
    this.toggleNotificationWindow();
  }
  else {
    this.flushAll(true);
  }
};

Teambox.NotificationsBuffer.prototype.flushAll = function(nonotify) {
  var flushBuffer = this.notifications.clone();
  this.notifications.clear();
  for (var i = 0; i < flushBuffer.length; i++) {
    var notification = flushBuffer.shift();
    if (!nonotify) {
      notification.notify();
    }
  };
  this.toggleNotificationWindow(true);
  this.toggleNotificationsIcon();
};

Teambox.Notifications = new Teambox.NotificationsBuffer();

Teambox.ActivityNotifier = {
  notificationForComments: function(activity) {
    return new Teambox.Notification(function() {
      var thread = $("thread_" + activity.comment_target_type + '_' + activity.comment_target_id);
      if (thread) {
        var comment = thread.down('comment' + activity.target_id);

        if (activity.action === 'create') {
          var comments = thread.down('.comments');
          if (comments) {
            comments.insert(activity.markup, {position: 'top'});
          }
        }
        else if (comment) {
          if (activity.action === 'delete') {
            comment.remove();
          }
          else {
            Element.replace(comment, activity.markup);
          }
        }
      }
    });
  },
  notificationForThreads: function(activity) {
    return new Teambox.Notification(function() {
      var threads = $('activities'),
          thread = $("thread_" + activity.target_type + '_' + activity.target_id);

      if (thread) {
        if (activity.action === 'delete') {
          thread.remove();
        }
        else {
          Element.replace(thread, activity.markup);
        }
      }
      else {
        if (activity.action === 'create') {
          threads.insert(activity.markup, {position: 'top'});
        }
      }
    });
  },
  notificationForOthers: function(activity) {
    return new Teambox.Notification(function() {
      var threads = $('activities');

      if (thread) {
        if (activity.action === 'delete') {
          thread.remove();
        }
        else {
          Element.replace(thread, activity.markup);
        }
      }
      else {
        if (activity.action === 'create') {
          threads.insert(activity.markup, {position: 'top'});
        }
      }
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
      Teambox.Notifications.add(notification);
    }
  }
};

document.on('dom:loaded', function() {

  Teambox.Notifications.notificationsWindow = $(document.body).down('#show_new_content');
  Teambox.Notifications.notificationsIcon = $(document.body).down('#header_icons li.notifications_icon a');

  if (Teambox.Notifications.notificationsIcon) {
    document.on('#header_icons .notifications_icon:click', function(e) {
      event.preventDefault();
      Teambox.Notifications.toggleNotificationWindow(true);
    });
  }

  Teambox.pushServer.on('connect', function() {
    console.log("connected: ", this.socket.transport.sessionid);
  });

  Teambox.pushServer.on('disconnect', function() {
    console.log("disconnected: ");
  });


  if (window.my_user) {
    Teambox.pushServer.subscribe("/users/" + my_user.authentication_token, function(activity){
      console.log("Got activity: ", activity);
      Teambox.ActivityNotifier.notifyActivity(activity);
    });
  }
});

