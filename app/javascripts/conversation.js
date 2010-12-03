document.on('click', '.conversation_header .text_actions a[href$="/edit"]', function(e, link) {
  e.stop()
  link.up('.conversation_header').hide().next('form.edit_conversation').forceShow()
})

document.on('click', '.edit_conversation a[href="#cancel"]', function(e, link) {
  e.stop()
  link.up('.edit_conversation').hide().previous('.conversation_header').show()
})

document.on('ajax:success', 'form.edit_conversation:not(.convert-to-task)', function(e, form) {
  var name = form.down('input[name="conversation[name]"]').getValue()
  form.up('.content').select('.conversation_header h2, .conversation .thread_title a').invoke('update', name)
  form.hide().previous('.conversation_header').show()
});

document.on('ajax:success', 'form.edit_conversation.convert-to-task', function(e, form) {
  if ($$('.conversation_header').length == 1) {
    document.location.href = e.memo.responseText;
  }
  else {
    e.element().up('.thread').update(e.memo.responseText).highlight({ duration: 2 })
    Task.insertAssignableUsers();
  }
});

document.on('ajax:failure', 'form.edit_conversation.convert-to-task', function(e, form) {
  var field_name = e.memo.responseJSON.first()[0],
      message = e.memo.responseJSON.first()[1];
  form.down('#conversation_' + field_name).insert({after: "<p class='error'>" + message + "</p>"});
})


document.on('click', '#user_all', function(e, el) {
  var target = e.element();
  var enabled = target.checked;
  $$('.watchers .user input').each(function(el){
    el.checked = enabled;
  });
});

document.on('click', '.watchers .user input', function(e, el) {
  var target = e.element();
  if (!target.checked)
    $('user_all').checked = false;
});


var toggleConvertToTaskForm = function(e, el, recurse) {
  e.stop();

  var form = el.up('form.new_comment.edit_conversation'),
      target = form.down('span.convert_to_task a'),
      panel = form.down('div.convert_to_task'),
      submit = form.down('.submit', 1),
      attach = form.down('.attach');
  panel.select('select,input').each(function(e) {e.disabled = !e.disabled;});
  panel.select('#conversation_task_list_id').each(function(select) {
    if (select.options[0].value == '' && !recurse) {
      var projectId = select.up('form').getAttribute('data-project-id');
      TaskList.populateTaskListSelect(projectId, select, function() {
        toggleConvertToTaskForm(e,el,true);
      });
    }
  });

  form.toggleClassName('not-new-comment');
  form.toggleClassName('convert-to-task');
  // /projects/earthworks/conversations/5/convert_to_task
  if (form.action.endsWith('/convert_to_task')) {
    form.action = form.action.gsub(/\/convert_to_task/,'');
  }
  else {
    form.action = form.action + '/convert_to_task';
  }

  [target,panel,submit,attach].invoke('toggle');
};

document.on('click', 'span.convert_to_task a', toggleConvertToTaskForm);
document.on('click', 'div.convert_to_task a.cancel', toggleConvertToTaskForm);

