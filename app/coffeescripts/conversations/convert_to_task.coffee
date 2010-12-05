# Convert conversation to task

# Shows or hides the Convert to Task form, enabling or disabling the controls
toggleConvertToTaskForm = (e, el, recurse) ->
  e.stop()
  
  form = el.up('form.new_comment.edit_conversation')
  target = form.down('span.convert_to_task a')
  panel = form.down('div.convert_to_task')
  submit = form.down('.submit', 1)
  attach = form.down('.attach')
  
  panel.select('select,input').each (e) ->
    e.disabled = !e.disabled
  
  panel.select('#conversation_task_list_id').each (select) ->
    if select.options[0].value == '' && !recurse
      projectId = select.up('form').getAttribute('data-project-id')
      TaskList.populateTaskListSelect projectId, select, ->
        toggleConvertToTaskForm e, el, true
  
  form.toggleClassName('not-new-comment')
  form.toggleClassName('convert-to-task')

  # URLs look like /projects/earthworks/conversations/5/convert_to_task
  if form.action.endsWith '/convert_to_task'
    form.action = form.action.gsub /\/convert_to_task/, ''
  else
    form.action = form.action + '/convert_to_task'
  
  [target,panel,submit,attach].invoke('toggle')

# Open or close the Convert to Task form
document.on 'click', 'span.convert_to_task a', toggleConvertToTaskForm
document.on 'click', 'div.convert_to_task a.cancel', toggleConvertToTaskForm

# If we succeed converting to a task..
document.on 'ajax:success', 'form.edit_conversation.convert-to-task', (e, form) ->
  # .. we redirect if we are on the Conversation#show view
  if $$('.conversation_header').length == 1
    document.location.href = e.memo.responseText
  # .. or we replace the thread by the newly converted task
  else
    e.element().up('.thread').update(e.memo.responseText).highlight duration: 2
    Task.insertAssignableUsers()

# If converting to task fails, we display an error message explaining why
document.on 'ajax:failure', 'form.edit_conversation.convert-to-task', (e, form) ->
  field_name = e.memo.responseJSON.first()[0]
  message = e.memo.responseJSON.first()[1]
  form.down("#conversation_#{field_name}").insert after: "<p class='error'>#{message}</p>"
