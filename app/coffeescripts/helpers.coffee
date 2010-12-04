window.Helpers =

  status_transition: (comment) ->
    text = ""
    status_code = ['new', 'open', 'hold', 'resolved', 'rejected']
    return if @target_type != "Task"

    if @previous_status?
      status = status_code[@previous_status]
      text += "<span class='task_status task_status_#{status}'>#{status}</span> "
      text += "<span class='arr status_arr'>→</span> "

    if @status?
      status = status_code[@status]
      text += "<span class='task_status task_status_#{status}'>#{status}</span> "

    return text

  date_transition: (comment) ->
    return ""

  thread_to_html: (thread) ->
    if thread.type == "Conversation" && thread.simple
      # TODO: check case where there are 0 comments
      template = ThreadTemplates.conversation.simple
      thread.first_comment = thread.comments.shift()
    thread.is_task = ->
      return @type == "Task"
    thread.template = ->
      switch thread.type
        when "Task"
          return ThreadTemplates.task
        when "Conversation"
          return if @simple then ThreadTemplates.conversation.simple else ThreadTemplates.conversation.normal
        else
          return "<p>Undefined template: {{type}} for thread {{id}}</p>"

    return Mustache.to_html(thread.template(), thread, { comment: ThreadTemplates.comment, first_comment: ThreadTemplates.first_comment })
