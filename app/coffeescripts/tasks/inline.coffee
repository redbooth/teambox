window.InlineTasks =

  toggleFold: (task) ->
    block_id = "inline_"+task.readAttribute("id")

    if task.hasClassName('expanded')
      task.removeClassName('expanded')
      new Effect.BlindUp block_id, duration: 0.5
      new Effect.Fade task.down('.expanded_actions'), duration: 0.5
      setTimeout (-> $(block_id).remove()), 500

    else
      unless task.down('.loading_icon')
        task.down('span.task_status').insert before: "<div class='loading_icon'> </div>"
        task.down('span.task_status').hide()

      new Ajax.Request task.down('a.name').readAttribute('href')+".frag",
        method: "get"
        onSuccess: (r) ->
          task.down('.loading_icon').remove()
          task.down('span.task_status').show()
          block = "<div class='task_inline' style='display:none' id='#{block_id}'>#{r.responseText}</div>"
          task.insert bottom: block
          new Effect.BlindDown block_id, duration: 0.5
          new Effect.Appear task.down('.expanded_actions'), duration: 0.5
          task.addClassName('expanded')
          format_posted_date()
          Task.insertAssignableUsers()
        onFailure: (r) ->
          task.down('.loading_icon').remove()
          task.down('span.task_status').show()

# Expand/collapse task threads inline in TaskLists#index
document.on 'click', '.task_list_container a.name, .task_list_container a.hide', (e, el) ->
  return if e.isMiddleClick()
  e.stop()
  InlineTasks.toggleFold el.up('.task')

# Update the parent task when commenting from a task thead that's been expanded inline
document.on 'ajax:success', '.task_inline form', (e, form) ->
  task = form.up('.task.expanded')
  return unless task

  task_data = e.memo.headerJSON

  status = task_data.status
  status_name = $w("new open hold resolved rejected")[status]

  person = task_data.assigned_id
  is_assigned_to_me = (status == 1) && my_projects[person]

  # Cleanup the current status of the task
  task.className = task.className.replace(/(^|\s+)user_(.+?)(\s+|$)/, ' ').strip()
  task.className = task.className.replace(/(^|\s+)status_(.+?)(\s+|$)/, ' ').strip()
  task.down('.assigned_user') && task.down('.assigned_user').remove()

  # Mark as mine if it's assigned to me
  if is_assigned_to_me then task.addClassName('mine') else task.removeClassName('mine')

  # Update the status of the task
  task.addClassName('status_'+status_name)

  # Show new assigned user name if there's an assigned user
  if status == 1
    task.addClassName('user_'+task_data.assigned.user_id)
    short_name = task_data.assigned.user.last_name
    task.down('a.name').insert({after: " <span class='assigned_user'>"+short_name+"</span> "})

  # Hide dates for resolved tasks
  if status == 3 || status == 4
    task.down('.assigned_date') && task.down('.assigned_date').remove()
