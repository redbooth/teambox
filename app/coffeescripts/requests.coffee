window.ApiRequest = ->

  # Evaluates JSON from the API and adds findRef() method to the collection
  @parse = (responseText) ->
    @json = eval "(#{responseText})"
    @json.findRef = (id, type) ->
      @references.detect (i) ->
        (i.id == id) && (i.type == type)
    return @json

  # Makes an API request to `url`, parses the resulting JSON and calls `callback`
  @request = (url, callback) ->
    self = this
    new Ajax.Request url,
      method: 'get',
      onSuccess: (response) ->
        self.parse response.responseText
        callback.bind(self).call() if callback
      onFailure: ->
        alert "Couldn't reach the server"

  # Gets all tasks for the current user, populates `tasks` and `task_lists`
  @getTasks = (callback) ->
    @request "/api/1/tasks", ->
      self = this
      tasks = @json.objects

      task_lists = tasks.collect((task) ->
        self.json.findRef task.task_list_id, "TaskList"
      ).uniq()

      task_lists = task_lists.collect (task_list) ->
        task_list.tasks = tasks.select( (task) ->
          task.task_list_id == task_list.id
        ).collect( (task) ->
          task.status_class = (['new', 'open', 'hold', 'resolved', 'rejected'])[task.status]
          task
        )
        task_list
      
      callback { tasks: tasks, task_lists: task_lists } if callback

  @getThreads = (callback) ->
    @request "/api/1/activities", ->
      json = @json
      
      # Returns the parent model for an activity (Conversation, Task, Note, etc)
      returnParentThreads = (activity) ->
        ref = json.findRef activity.target_id, activity.target_type
        if ref.type == "Comment" # for comments, we look for the target Conversation or Task
          ref = json.findRef(ref.target_id, ref.target_type)
        if activity.user_id
          ref.user = json.findRef activity.user_id, "User"
        if activity.project_id
          ref.project = json.findRef ref.project_id, "Project"
        ref.created_at_msec = 1290121194000
        ref

      # Returns the array of comments referenced by a thread.
      fetchComments = (thread) ->
        if thread.first_comment_id # conversation or task, has comments
          comment_ids = [thread.first_comment_id].concat(thread.recent_comment_ids || []).sort().uniq()
          thread.comments = comment_ids.collect (id) ->
            comment = json.findRef(id, "Comment")
            comment.user = json.findRef(comment.user_id, "User")
            comment.status_transition = Helpers.status_transition
            comment.date_transition = Helpers.date_transition
            comment
        return thread

      # Collect activity threads and fetch their references (user, comments)
      threads = json.objects.collect(returnParentThreads).uniq().collect(fetchComments)
      callback(threads) if callback

  return {
    parse: @parse,
    request: @request,
    getTasks: @getTasks,
    getThreads: @getThreads
  }