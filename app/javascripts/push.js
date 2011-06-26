(function() {

  window.WEB_SOCKET_SWF_LOCATION = window.location.protocol + "//" + window.location.host  + "/WebSocketMain.swf";

  var ACTIVE_PATHS = [/^\/$/,/^\/projects\/?$/, /^\/projects\/[^\/]+\/?$/, /#!\/projects\/[^\/]+\/?$/, /^#!$/];

  var NotificationsController = function(app) {
    this.initialize(app);
  };

  _.extend(NotificationsController.prototype, Backbone.Events, {
      app: false
    , socket: false
    , initialize: function(app) {
        var sessionId = Cookie.read('_teambox-2_session');
        var meta = {
          teambox_session_id: sessionId
        };
        var user = app && app.my_user;

        if (user && user.get('authentication_token')) {
          meta.auth_token = user.get('authentication_token');
        }

        if (user && user.get('login')) {
          meta.login = user.get('login');
        }

        var port = function() {
          return ('https:' === document.location.protocol) ? 443 : 80;
        };

        var socket = new Juggernaut({
          host: "push." + document.location.host,
          port: port(),
          meta: meta,
          secure: ('https:' === document.location.protocol)
        });

        this.setApp(app);
        this.setSocket(socket);

        //TODO: When we replace JQuery we need to update this code
        jQuery.ajaxSetup({
          beforeSend: function(xhr, settings){
            if (Teambox.controllers.application.push_session_id) {
              xhr.setRequestHeader("X-PushSession-ID", Teambox.controllers.application.push_session_id);
            }
            return true;
          }
        });

        this.bind("activity:task", this.onThreadActivity);
        this.bind("activity:task:comment", this.onCommentActivity);
        this.bind("activity:conversation", this.onThreadActivity);
        this.bind("activity:conversation:comment", this.onCommentActivity);
        this.bind("activity:project", this.onProjectActivity);
        this.bind("activity:task_list", this.onActivity);
        this.bind("activity:person", this.onActivity);
        this.bind("activity:page", this.onActivity);
        this.bind("activity:note", this.onActivity);
        this.bind("activity:divider", this.onActivity);
        this.bind("activity:upload", this.onActivity);
      }
    , setApp: function(app) {
        this.app = app;
      }
    , setSocket: function(socket) {
        var self = this;

        socket.on('connect', function() {
          self.app.setPushSessionId(socket.sessionID);
          console.log("connected: ", socket.sessionID);
        });

        socket.on('disconnect', function() {
          self.app.setPushSessionId(false);
          console.log("disconnected: ");
        });

        socket.subscribe("/users/" + self.app.my_user.get('authentication_token'), function(message){
          var activity;
          try {
            activity = JSON.parse(message);
          }
          catch(err) {
            console.log('[Push Error]'  + err + ' parsing: ', message);
          }

          console.log("Received activity: ", activity);

          if (activity.push_session_id.toString() === self.app.push_session_id) {
            return;
          }

          var matchPath = function(r) {
              return (r.exec(window.location.hash) || r.exec(window.location.pathname) || []).length > 0;
          };

          if (ACTIVE_PATHS.any(matchPath)) {
            var project_level_matches = /#!\/projects\/([^\/]+)\/?$/.exec(window.location.hash) ||
                                        /^\/projects\/([^\/]+)\/?$/.exec(window.location.pathname);

            if (project_level_matches && (project_level_matches[1] === activity.project.permalink)) {
              self.notifyActivity(activity);
            }
            else if (!project_level_matches) {
              self.notifyActivity(activity);
            }
          }

        });

        this.socket = socket;
      }
    , notifyActivity: function(activity) {
        var eventName;
        if (activity.comment_target_type) {
          eventName = "activity:" + activity.comment_target_type.toLowerCase() + ":" + activity.target_type.toLowerCase();
        }
        else {
          eventName = "activity:" + activity.target_type.toLowerCase();
        }

        this.trigger(eventName, activity);
      }
    , onThreadActivity: function(activity) {
        var thread, target;

        switch(activity.action) {
          case 'create':
            this.app['my_' + activity.target_type.toLowerCase() + 's'].add(activity.target);
            this.app.my_threads.add(activity.target);
            break;
          case 'update':
            thread = this.app['my_' + activity.target_type.toLowerCase() + 's'].get(activity.target_id);
            if (thread) {
              thread.set(activity.changes);
            }
            break;
          case 'delete':
            target = this.app['my_' + activity.target_type.toLowerCase() + 's'].get(activity.target_id);
            if (target) {
              this.app['my_' + activity.target_type.toLowerCase() + 's'].remove(target);
            }
            if (thread) {
              this.app.my_threads.remove(thread);
            }
            break;

          default:
            console.log("Unkown activity type");
        }
     }
    , onCommentActivity: function(activity) {
        var thread, comment, 
            id   = activity.comment_target_id, 
            type = activity.comment_target_type;

        switch(activity.action) {
          case 'create':
            thread = this.app.my_threads.getByIdAndClass(id, type);
            if (thread) thread.trigger('comment:added', activity.target);

            break;
          case 'update':
            thread = this.app.my_threads.getByIdAndClass(id, type);
            if (thread) {
              //TODO: Update comment in thread's comments collection and trigger thread change event
              comment = thread.recent_comments.get(activity.target_id);
              if (comment) {
                comment.set(activity.changes);
                thread.change();
              }
            }
            break;
          case 'delete':
            thread = this.app.my_threads.getByIdAndClass(id, type);
            if (thread) {
              //TODO: Update comment in thread's comments collection and trigger thread change event
              comment = thread.recent_comments.get(activity.target_id);
              if (comment) {
                thread.recent_comments.remove(comment);
                thread.change();
              }
            }
            break;

          default:
            console.log("Unkown activity type");
        }
      }
    , onProjectActivity: function(activity) {
        var thread, project;

        switch(activity.action) {
          case 'create':
            this.app.my_threads.add(activity);
            this.app.my_projects.add(activity);
            break;
          case 'delete':
            project = this.app.my_projects.get(activity.target_id);
            thread  = this.app.my_threads.get(activity.target_id); 
            if (project) {
              this.app.my_projects.remove(project);
            }
            if (thread) {
              this.app.my_threads.remove(thread);
            }
            break;

          default:
            console.log("Unkown activity type");
        }
      }
    , onActivity: function(activity) {
        var thread;
        switch(activity.action) {
          case 'create':
            this.app.my_threads.add(activity);
            break;
          case 'delete':
            thread  = this.app.my_threads.get(activity.target_id); 
            if (thread) {
              this.app.my_threads.remove(thread);
            }

            break;

          default:
            console.log("Unkown activity type");
        }
      }
  });

  //exports
  Teambox.Controllers.Notifications = NotificationsController;

}());

