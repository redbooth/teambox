# Editing the title of a Conversation

# Clicking on "Edit" from Conversation#show displays the edit title view
document.on 'click', '.conversation_header .text_actions a[href$="/edit"]', (e, link) ->
  e.stop()
  link.up('.conversation_header').hide().next('form.edit_conversation').forceShow()

# Clicking "Cancel" on the edit header view hides the window
document.on 'click', '.edit_conversation a[href="#cancel"]', (e, link) ->
  e.stop()
  link.up('.edit_conversation').hide().previous('.conversation_header').show()

# After editing the conversation title, we display it
document.on 'ajax:success', 'form.edit_conversation:not(.convert-to-task)', (e, form) ->
  name = form.down('input[name="conversation[name]"]').getValue()
  form.up('.content').select('.conversation_header h2, .conversation .thread_title a').invoke('update', name)
  form.hide().previous('.conversation_header').show()

