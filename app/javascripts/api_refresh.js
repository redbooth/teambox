var url = "http://teambox.local/api/1/activities" //"?since_id=40"

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

document.on("dom:loaded", function() {
  
  new Ajax.Request(url, {
    method: 'get',
    onSuccess: function(response) {
      var json = eval('('+response.responseText+')')

      json.findRef = function (id, type) { 
        return this.references.detect( function(i) {
          return ((i.id == id) && (i.type == type));
        })
      }

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
          thread.comments = comment_ids.collect( function(id) {
            var comment = json.findRef(id, "Comment")
            comment.user = json.findRef(comment.user_id, "User")
            return comment
          })
        }
        return thread
      }

      // Collect activity threads and fetch their references (user, comments)
      //var
      threads = json.objects.collect(returnParentThreads).uniq().collect(fetchComments)

      // Render the HTML for each thread
      var threads_html = threads.collect(function(thread) {

        if (thread.comments) {
          thread.comments = thread.comments.collect( function(comment) {
            comment.created_at_msec = 1290121194000
            comment.editable_before_msec = 1290121194000
            comment.status_transition = renderStatusTransition(comment)
            comment.date_transition = renderDateTransition(comment)
            return comment
          })
        }

        var template = ThreadTemplates.conversation.simple
      
        switch(thread.type) {
          case "Task":
            thread.is_task = true
            template = ThreadTemplates.task
            break
          case "Conversation":
            if (thread.simple) { // check case where there are 0 comments
              template = ThreadTemplates.conversation.simple
              thread.first_comment = thread.comments.shift()
            } else {
              template = ThreadTemplates.conversation.normal
            }
            break
          default:
            template = "<p>Undefined template: {{type}} for thread {{id}}</p>"
        }

        return Mustache.to_html(template, thread, { comment: ThreadTemplates.comment, first_comment: ThreadTemplates.first_comment })
      }).join("")

      $('activities').insert({top: threads_html})
      format_posted_date()
    }
  })

})