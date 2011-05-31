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
