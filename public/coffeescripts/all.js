(function() {
  window.ApiRequest = function() {
    this.parse = function(responseText) {
      this.json = eval("(" + (responseText) + ")");
      this.json.findRef = function(id, type) {
        return this.references.detect(function(i) {
          return (i.id === id) && (i.type === type);
        });
      };
      return this.json;
    };
    this.request = function(url, callback) {
      var self;
      self = this;
      return new Ajax.Request(url, {
        method: 'get',
        onSuccess: function(response) {
          self.parse(response.responseText);
          if (callback) {
            return callback.bind(self).call();
          }
        },
        onFailure: function() {
          return alert("Couldn't reach the server");
        }
      });
    };
    this.getTasks = function(callback) {
      return this.request("/api/1/tasks", function() {
        var self, task_lists, tasks;
        self = this;
        tasks = this.json.objects;
        task_lists = tasks.collect(function(task) {
          return self.json.findRef(task.task_list_id, "TaskList");
        }).uniq();
        task_lists = task_lists.collect(function(task_list) {
          task_list.tasks = tasks.select(function(task) {
            return task.task_list_id === task_list.id;
          }).collect(function(task) {
            task.status_class = (['new', 'open', 'hold', 'resolved', 'rejected'])[task.status];
            return task;
          });
          return task_list;
        });
        if (callback) {
          return callback({
            tasks: tasks,
            task_lists: task_lists
          });
        }
      });
    };
    this.getThreads = function(callback) {
      return this.request("/api/1/activities", function() {
        var fetchComments, json, returnParentThreads, threads;
        json = this.json;
        returnParentThreads = function(activity) {
          var ref;
          ref = json.findRef(activity.target_id, activity.target_type);
          if (ref.type === "Comment") {
            ref = json.findRef(ref.target_id, ref.target_type);
          }
          if (activity.user_id) {
            ref.user = json.findRef(activity.user_id, "User");
          }
          if (activity.project_id) {
            ref.project = json.findRef(ref.project_id, "Project");
          }
          ref.created_at_msec = 1290121194000;
          return ref;
        };
        fetchComments = function(thread) {
          var comment_ids;
          if (thread.first_comment_id) {
            comment_ids = [thread.first_comment_id].concat(thread.recent_comment_ids || []).sort().uniq();
            thread.comments = comment_ids.collect(function(id) {
              var comment;
              comment = json.findRef(id, "Comment");
              comment.user = json.findRef(comment.user_id, "User");
              comment.status_transition = Helpers.status_transition;
              comment.date_transition = Helpers.date_transition;
              return comment;
            });
          }
          return thread;
        };
        threads = json.objects.collect(returnParentThreads).uniq().collect(fetchComments);
        if (callback) {
          return callback(threads);
        }
      });
    };
    return {
      parse: this.parse,
      request: this.request,
      getTasks: this.getTasks,
      getThreads: this.getThreads
    };
  };
}).call(this);
(function() {
  window.Load = {
    Activities: function() {
      var activities, request;
      activities = Store.get("all/activities");
      if (activities) {
        $('content').insert({
          top: activities
        });
        return format_posted_date();
      } else {
        request = new ApiRequest();
        return request.getThreads(function(threads) {
          var threads_html;
          threads_html = threads.collect(Helpers.thread_to_html).join("");
          $('content').insert({
            top: threads_html
          });
          format_posted_date();
          return Store.set("all/activities", threads_html);
        });
      }
    },
    Tasks: function() {
      var renderTasks, request, task_lists, tasks;
      tasks = Store.get("all/tasks");
      task_lists = Store.get("all/task_lists");
      renderTasks = function() {
        var text;
        text = Mustache.to_html(TaskTemplates.task_lists, {
          task_lists: task_lists
        }, {
          task_list: TaskTemplates.task_list,
          task: TaskTemplates.task
        });
        return $('content').insert({
          top: text
        });
      };
      if (!tasks || !task_lists) {
        request = new ApiRequest();
        return request.getTasks(function(data) {
          tasks = data.tasks;
          task_lists = data.task_lists;
          Store.set("all/tasks", tasks);
          Store.set("all/task_lists", task_lists);
          return renderTasks();
        });
      } else {
        return renderTasks();
      }
    }
  };
}).call(this);
(function() {
  window.Helpers = {
    status_transition: function(comment) {
      var _ref, status, status_code, text;
      text = "";
      status_code = ['new', 'open', 'hold', 'resolved', 'rejected'];
      if (this.target_type !== "Task") {
        return null;
      }
      if (typeof (_ref = this.previous_status) !== "undefined" && _ref !== null) {
        status = status_code[this.previous_status];
        text += ("<span class='task_status task_status_" + (status) + "'>" + (status) + "</span> ");
        text += "<span class='arr status_arr'>→</span> ";
      }
      if (typeof (_ref = this.status) !== "undefined" && _ref !== null) {
        status = status_code[this.status];
        text += ("<span class='task_status task_status_" + (status) + "'>" + (status) + "</span> ");
      }
      return text;
    },
    date_transition: function(comment) {
      return "";
    },
    thread_to_html: function(thread) {
      var template;
      if (thread.type === "Conversation" && thread.simple) {
        template = ThreadTemplates.conversation.simple;
        thread.first_comment = thread.comments.shift();
      }
      thread.is_task = function() {
        return this.type === "Task";
      };
      thread.template = function() {
        switch (thread.type) {
          case "Task":
            return ThreadTemplates.task;
          case "Conversation":
            return this.simple ? ThreadTemplates.conversation.simple : ThreadTemplates.conversation.normal;
          default:
            return "<p>Undefined template: {{type}} for thread {{id}}</p>";
        }
      };
      return Mustache.to_html(thread.template(), thread, {
        comment: ThreadTemplates.comment,
        first_comment: ThreadTemplates.first_comment
      });
    }
  };
}).call(this);
(function() {
  document.on("dom:loaded", function() {
    Store.clear();
    if (location.pathname.match("static/activities")) {
      Load.Activities();
    }
    if (location.pathname.match("static/tasks")) {
      return Load.Tasks();
    }
  });
  document.on("click", "a#clear_store", function(e) {
    Store.clear();
    alert("Storage cleared!");
    return e.stop();
  });
}).call(this);
