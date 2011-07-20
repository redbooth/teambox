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

  //If we're on the conversation page, hide form and show the header
  var header = form.previous('.conversation_header');
  if (header) {
    form.hide();
    header.show();
  }
});

document.on('ajax:success', 'form.edit_conversation.convert-to-task', function(e, form) {
  var person = form['conversation[assigned_id]'].getValue();
  var task_count = Number($('open_my_tasks').innerHTML)
  var is_assigned_to_me = my_projects[person]

  if (is_assigned_to_me) {
    task_count += 1
    $('open_my_tasks').update(task_count)
  }
  if ($$('.conversation_header').length == 1) {
    document.location.href = e.memo.responseText;
  }
  else {
    e.element().up('.thread').update(e.memo.responseText).highlight({ duration: 2 })
    Task.insertAssignableUsers();
  }
});

document.on('ajax:failure', 'form.edit_conversation.convert-to-task', function(e, form) {
  var message = $H(e.memo.responseJSON)
	message.each( function(error) {
    form.down('#conversation_name').insert({after: "<p class='error'>" + message + "</p>"})
	})
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
      google_docs = form.down('.google_docs_attachment');
      attach = form.down('.attach');
  panel.select('select,input').each(function(e) {e.disabled = !e.disabled;});

  //reenable convert to task submit button
  //(If we previously submit a comment from a conversation
  //the default rails action for elements with disable-with disables it)
  panel.select('input[type=submit]').each(function(input) {
    if (!form.down('select').disabled) {
      input.disabled = false;
    }
  });

  panel.select('#conversation_task_list_id').each(function(select) {
    if (select.options[0].value == '' && !recurse) {
      var projectId = select.up('form').getAttribute('data-project-id');
      TaskList.populateTaskListSelect(projectId, select, function() {
        toggleConvertToTaskForm(e,el,true);
      });
    }
  });

  //Undisable _method input field when showing the convert to task form.
  form.select('input[name=_method]').each(function(input) {
    input.disabled = !input.disabled;
  });

  //Avoid default comment actions for convert to task
  form.toggleClassName('not-new-comment');
  form.toggleClassName('convert-to-task');

  //Activate client-side validation for required inputs
  form.toggleClassName('required');

  // Normally, convert to task form submits to comments controller
  // Ensure we change the action accordingly
  if (form.action.endsWith('/convert_to_task')) {
    form.action = form.action.gsub(/\/convert_to_task/,'/comments');
  }
  else {
    form.action = form.action.gsub(/\/comments/,'');
    form.action = form.action + '/convert_to_task';
  }

  [target,panel,submit,attach,google_docs].invoke('toggle');
};

document.on('click', 'span.convert_to_task a', toggleConvertToTaskForm);
document.on('click', 'div.convert_to_task a.cancel', toggleConvertToTaskForm);

// Since the conversation comments form is now a form for 
// an existing conversation (rather than just a new comment as previously)
// when submitting a comment from a conversation form, we disable the _method input field
// (which would be put for the conversation) as new Comments can only be POSTed.
//
var disableConversationHttpMethodField = function(e) {
  $$('form.new_comment.edit_conversation input[name=_method]').each(function(input) {
    input.disabled = true;
  });
}

//disable _method input field for conversation forms on dom ready
document.observe('dom:loaded', disableConversationHttpMethodField);
