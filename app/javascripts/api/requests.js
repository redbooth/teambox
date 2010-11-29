ApiRequest = function ApiRequest() {

  // Evaluates JSON from the API and adds findRef() method to the collection
  this.parse = function(responseText) {
    this.json = eval('('+responseText+')')
    this.json.findRef = function(id, type) { 
      return this.references.detect(function(i) {
        return ((i.id == id) && (i.type == type))
      })
    }
    return this.json
  }

  // Makes an API request to `url`, parses the resulting JSON and calls `callback`
  this.request = function(url, callback) {
    var self = this
    new Ajax.Request(url, {
      method: 'get',
      onSuccess: function(response) {
        self.parse(response.responseText)
        if (callback) callback.bind(self).call()
      },
      onFailure: function() {
        alert("Couldn't reach the server")
      }
    })
  }

  // Gets all tasks for the current user, populates `tasks` and `task_lists`
  this.getTasks = function(callback) {
    this.request("/api/1/tasks", function() {
      var self = this
      var tasks = this.json.objects

      var task_lists = tasks.collect(function(task) {
        return self.json.findRef(task.task_list_id, "TaskList")
      }).uniq()

      task_lists = task_lists.collect(function(task_list) {
        task_list.tasks = tasks.select(function(task) {
          return task.task_list_id == task_list.id
        })
        return task_list
      })
      
      if (callback) callback({ tasks: tasks, task_lists: task_lists })
    })
  }

  this.getThreads = function(callback) {
    this.request("/api/1/activities", function() {
      var json = this.json
      
      // Returns the parent model for an activity (Conversation, Task, Note, etc)
      var returnParentThreads = function(activity) {
        var ref = json.findRef(activity.target_id, activity.target_type)
        if (ref.type == "Comment") // for comments, we look for the target Conversation or Task
          ref = json.findRef(ref.target_id, ref.target_type)
        if (activity.user_id)
          ref.user = json.findRef(activity.user_id, "User")
        if (activity.project_id)
          ref.project = json.findRef(ref.project_id, "Project")
        ref.created_at_msec = 1290121194000
        return ref
      }

      // Returns the array of comments referenced by a thread.
      var fetchComments = function(thread) {
        if (thread.first_comment_id) { // conversation or task, has comments
          var comment_ids = [thread.first_comment_id].concat(thread.recent_comment_ids || []).sort().uniq()
          thread.comments = comment_ids.collect(function(id) {
            var comment = json.findRef(id, "Comment")
            comment.user = json.findRef(comment.user_id, "User")
            comment.status_transition = Helpers.status_transition
            comment.date_transition = Helpers.date_transition
            return comment
          })
        }
        return thread
      }

      // Collect activity threads and fetch their references (user, comments)
      var threads = json.objects.collect(returnParentThreads).uniq().collect(fetchComments)
      if (callback) callback(threads)
    })
  }

}
