if ( typeof( window['Teambox'] ) == "undefined" ) {
  window.Teambox = {};
}

if ( typeof( window['console'] ) == "undefined" ) {
  window.console = {
    messages: [],
    log: function() {
      var args = Array.prototype.slice.call(arguments);
      this.messages.push(args.join(' '));
    }
  };
}

Teambox.User = {};

Teambox.Notification = function(data, action) {
  this.data = data;
  this.action = action;
};

Teambox.Notification.prototype.notify = function(callback) {
  if (this.action) {
    this.action();
  }

  if (callback) {
    callback();
  }
};

Teambox.NotificationsBuffer = function() {
  this.notifications = [];
  this.windowEntryTemplate = Handlebars.compile(Templates.notifications.entry);
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

Teambox.NotificationsBuffer.prototype.toggleNotificationWindow = function(notification, force) {
  if (this.notificationsWindow) {
    if (!this.notificationsWindow.visible()) {
      if (this.notifications.length > 0) {
        Effect.toggle(this.notificationsWindow.id, 'blind', { duration: 0.5 });
        var self = this;
        if (!force) {
          if (self.windowTimeout) {
            clearTimeout(self.windowTimeout);
          }
          self.windowTimeout = setTimeout(function() {
            if (self.notificationsWindow.visible()) {
              Effect.toggle(self.notificationsWindow.id, 'blind', { duration: 0.5 });
            }
          }, 1000*20);
        }
      }
    }
    else {
      if (!notification) {
        Effect.toggle(this.notificationsWindow.id, 'blind', { duration: 0.5 });
      }
    }
  }
};

//Add notification but flush if we reach 5 unread notifications
Teambox.NotificationsBuffer.prototype.addNotificationWindowEntry = function(notification) {
  if (notification.data) {
    var is_assigned_to_me = false,
        is_me,
        converted_to_task = false;

    converted_to_task = notification.data.target.record_conversion_id ? true : false;
    if (my_user) {
      is_assigned_to_me = notification.data.target.assigned_id && notification.data.target.assigned_id === my_user.id
      is_me = notification.data.user_id === my_user.id
    }

    var opts = { activity: notification.data};
    if (is_assigned_to_me && !converted_to_task) {
      opts.assigned_to_you = is_assigned_to_me;
    }
    else if (converted_to_task) {
      opts.converted_to_task = converted_to_task;
    }
    else if (notification.data.action_type === 'create_teambox_data'){
      opts.import = true
    }
    else if (notification.data.action_type === 'create_person'){
      if (is_me) {
        opts.i_joined_project = true
      }
      else {
        opts.joined_project = true
      }
    }
    else if (notification.data.action_type === 'delete_person'){
      if (is_me) {
        opts.i_left_project = true
      }
      else {
        opts.left_project = true
      }
    }
    else {
      opts.generic_case = true;
    }

    var markup = this.windowEntryTemplate(opts);
    this.notificationsWindow.down('ul').insert({bottom: markup});
  }
};

Teambox.NotificationsBuffer.prototype.clearNotificationWindow = function() {
  this.notificationsWindow.down('ul').childElements().each(function(e) {e.remove();});
};

Teambox.NotificationsBuffer.prototype.addNotification = function(notification) {
  this.notifications.push(notification);

  if (this.notifications.length < 5) {
    this.addNotificationWindowEntry(notification);
    this.toggleNotificationWindow(true);
    this.toggleNotificationsIcon();
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
          var scrollTarget = $(scrollToId),
              focussed_input = Teambox.User.currently_focussed_element;

          if (focussed_input && !focussed_input.value.empty()) {
            Effect.ScrollTo(focussed_input, {duration: 0.2, offset: -100});
            new Effect.Highlight(focussed_input, { startcolor: '#ffff99', endcolor: '#ffffff', queue: 'end' });
            setTimeout(2000, function() {
              focussed_input.focus();
            });
          }
          else if (scrollTarget) {
            Effect.ScrollTo(scrollTarget, {duration: 0.2, offset: -100});

            var comments = scrollTarget.down('.comments');
            if (comments) {
              new Effect.Highlight(comments, { startcolor: '#ffff99', endcolor: '#ffffff', queue: 'end' });
            }
            else {
              new Effect.Highlight(scrollTarget, { startcolor: '#ffff99', endcolor: '#ffffff', queue: 'end' });
            }
          }
      });
    }
  };

  Task.insertAssignableUsers();
  disableConversationHttpMethodField();

  this.toggleNotificationWindow(false, true);
  this.toggleNotificationsIcon();
  this.clearNotificationWindow();

};

Teambox.Notifications = new Teambox.NotificationsBuffer();

Teambox.ActivityNotifier = {
  notificationForComments: function(activity) {
    return new Teambox.Notification(activity, function() {
      var thread = $("thread_" + activity.comment_target_type.toLowerCase() + '_' + activity.comment_target_id);
      if (thread) {
        var comment = thread.down('#comment' + activity.target_id);

        if (activity.action === 'create') {
          var comments = thread.down('.comments');
          if (comments) {
            comments.insert({bottom: activity.markup});
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
        if (thread.hasClassName('collapsed')) {
          thread.removeClassName('collapsed');
        }
      }
    });
  },
  notificationForThreads: function(activity) {
    return new Teambox.Notification(activity, function() {
      var find_thread = function() {
        return $("thread_" + activity.target_type.toLowerCase() + '_' + activity.target_id);
      };

      var threads = $('activities'),
          thread = find_thread();

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

          if (activity.target_type === 'Task' && activity.target.record_conversion_id) {

            //Handle convert-to-task
            var old_conversion_thread = $("thread_" + activity.target.record_conversion_type.toLowerCase() + '_' + activity.target.record_conversion_id);
            if (old_conversion_thread) {

              focussed_element = Teambox.User.currently_focussed_element;
              if (focussed_element) {
                var parentThread = focussed_element.up('.thread');
                if (parentThread && parentThread.id === old_conversion_thread.id) {
                  //get current tet user has typed
                  var currentValue = focussed_element.value;

                  //replace thread
                  Element.replace(old_conversion_thread, activity.markup);

                  //find new thread and readd text user typed to new textarea
                  var newThread = find_thread();
                  if (newThread) {
                    var newInput = newThread.down('textarea');
                    if (newInput) {
                      newInput.value = currentValue;
                      Teambox.User.currently_focussed_element = newInput;
                    }
                  }
                }
                else {
                  Element.replace(old_conversion_thread, activity.markup);
                }
              }
              else {
                Element.replace(old_conversion_thread, activity.markup);
              }
            }
            else {
              threads.insert({top: activity.markup});
            }
          }
          else {
            threads.insert({top: activity.markup});
          }
        }
      }
    });
  },
  notificationForOthers: function(activity) {
    return new Teambox.Notification(activity, function() {
      var threads = $('activities'),
          thread = $("activity_" + activity.target_type.toLowerCase() + '_' + activity.target_id);

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
          threads.insert({top: activity.markup});
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
  Teambox.Notifications.toggleNotificationWindow(true);
});

Teambox.User.handleFocusEvent = function(e) {
  var event = e || window.event,
      target = event.target || event.srcElement;
  if (target && ['INPUT','TEXTAREA'].indexOf(target.tagName) != -1) {
    Teambox.User.currently_focussed_element = target;
  }
};

// IE
document.onfocusin = Teambox.User.handleFocusEvent;
document.onfocusout = Teambox.User.handleFocusEvent;

if (document.addEventListener) {
  document.addEventListener('focus',Teambox.User.handleFocusEvent,true);
}


document.on('dom:loaded', function() {

  Teambox.Notifications.notificationsWindow = $(document.body).down('#show_new_content');
  Teambox.Notifications.notificationsIcon = $(document.body).down('#header_icons li.notifications_icon a');

  if (Teambox.Notifications.notificationsIcon) {
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
});

