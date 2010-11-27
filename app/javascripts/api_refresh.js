status_code = ['new', 'open', 'hold', 'resolved', 'rejected']

renderStatusTransition = function(comment) {
  var text = "", status
  if (comment.target_type != "Task") { return }

  if (comment.previous_status != null) {
    status = status_code[comment.previous_status]
    text += "<span class='task_status task_status_"+status+"'>"+status+"</span> "
    text += "<span class='arr status_arr'>→</span> "
  }
  if (comment.status != null) {
    status = status_code[comment.status]
    text += "<span class='task_status task_status_"+status+"'>"+status+"</span> "
  }
  return text
}

renderDateTransition = function(comment) {
  return ""
}

thread_to_html = function(thread) {

  if (thread.type == "Conversation" && thread.simple) {
    // TODO: check case where there are 0 comments
    template = ThreadTemplates.conversation.simple
    thread.first_comment = thread.comments.shift()
  }
  thread.is_task = function() { return this.type == "Task" }
  thread.template = function() {
    switch(thread.type) {
      case "Task":
        return ThreadTemplates.task
      case "Conversation":
        return this.simple ? ThreadTemplates.conversation.simple : ThreadTemplates.conversation.normal
      default:
        return "<p>Undefined template: {{type}} for thread {{id}}</p>"
    }
  }
  
  return Mustache.to_html(thread.template(), thread, { comment: ThreadTemplates.comment, first_comment: ThreadTemplates.first_comment })
}

Load = {
  Activities: function() {
    var activities = Store.get("all/activities")
    if (activities) {
      $('content').insert({top: activities})
      format_posted_date()
    } else {
      (new ApiRequest).getThreads(function(threads) {
        var threads_html = threads.collect(thread_to_html).join("")
        $('content').insert({top: threads_html})
        format_posted_date()
        Store.set("all/activities", threads_html)
      })
    }
  },
  Tasks: function() {
    var tasks = Store.get("all/tasks"),
        task_lists = Store.get("all/task_lists")
    var renderTasks = function() {
      var text = Mustache.to_html(
        TaskTemplates.task_lists, { task_lists: task_lists }, {
          task_list: TaskTemplates.task_list,
          task: TaskTemplates.task
      })
      $('content').insert({top: text})
    }
    if (!tasks || !task_lists) {
      (new ApiRequest).getTasks(function(data) {
        tasks = data.tasks, task_lists = data.task_lists
        Store.set("all/tasks", tasks)
        Store.set("all/task_lists", task_lists)
        renderTasks()
      })
    } else {
      renderTasks()
    }
  }
}

document.on("dom:loaded", function() {
  //Store.clear()
  if (location.pathname.match("static/activities")) Load.Activities()
  if (location.pathname.match("static/tasks")) Load.Tasks()
})

document.on("click", "a#clear_store", function(e) {
  Store.clear()
  alert("Storage cleared!")
  e.stop()
})