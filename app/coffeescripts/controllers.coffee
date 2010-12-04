window.Load =
  Activities: ->
    activities = Store.get "all/activities"
    if activities
      $('content').insert top: activities
      format_posted_date()
    else
      request = new ApiRequest
      request.getThreads (threads) ->
        threads_html = threads.collect(Helpers.thread_to_html).join("")
        $('content').insert top: threads_html
        format_posted_date()
        Store.set "all/activities", threads_html

  Tasks: ->
    tasks = Store.get "all/tasks"
    task_lists = Store.get "all/task_lists"
    renderTasks = ->
      text = Mustache.to_html(
        TaskTemplates.task_lists,
          { task_lists: task_lists },
          { task_list: TaskTemplates.task_list, task: TaskTemplates.task }
      )
      $('content').insert top: text

    if !tasks or !task_lists
      request = new ApiRequest
      request.getTasks (data) ->
        tasks = data.tasks
        task_lists = data.task_lists
        Store.set "all/tasks", tasks
        Store.set "all/task_lists", task_lists
        renderTasks()
    else
      renderTasks()
