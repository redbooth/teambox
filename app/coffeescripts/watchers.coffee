# Selecting Watchers for a new conversation

# When clicking on the "All people" checkbox, mark all users as watchers
document.on 'click', '.watchers #user_all', (e, el) ->
  enabled = e.element().checked
  $$('.watchers .user input').each (el) ->
    el.checked = enabled

# When unchecking a user, then we should uncheck "All people" too
document.on 'click', '.watchers .user input', (e, el) ->
  if !e.element().checked
    $('user_all').checked = false
