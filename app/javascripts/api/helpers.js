Helpers = {

  status_transition: function(comment) {
    var text = "", status
    var status_code = ['new', 'open', 'hold', 'resolved', 'rejected']
    if (this.target_type != "Task") return

    if (this.previous_status != null) {
      status = status_code[this.previous_status]
      text += "<span class='task_status task_status_"+status+"'>"+status+"</span> "
      text += "<span class='arr status_arr'>→</span> "
    }
    if (this.status != null) {
      status = status_code[this.status]
      text += "<span class='task_status task_status_"+status+"'>"+status+"</span> "
    }
    return text
  },

  date_transition: function(comment) {
    return ""
  },

  thread_to_html: function(thread) {
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

}
