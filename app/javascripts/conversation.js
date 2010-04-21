var Conversation = {
  // Destruction handler
  destroy: function(element, url) {
    new Ajax.Request(url, {
      method: 'delete',
      asynchronous: true,
      evalScripts: true,
      onLoading: function() {
        Actions.setLoading(element, true);
      },
      onSuccess: function(response){
        // ...
        setTimeout(function(){TaskList.updatePrimer();}, 0);
      },
      onFailure: function(response){
        Actions.setLoading(element, false);
      }
    });
  }	
};

document.on('click', 'a.edit_conversation_link', function(e, el) {
  e.stop();
  Jenny.toggleElement(el); // edit form on task list show
});

document.on('click', 'a.delete_conversation_link', function(e, el) {
  e.stop();
  if (confirm(el.readAttribute('aconfirm')))
    Conversation.destroy(el, el.readAttribute('action_url'));
});

document.on('click', '#user_all', function(e, el) {
  e.stop();
  var target = e.element();
  var enabled = target.checked;
  $$('.watchers .user input').each(function(el){
    el.checked = enabled;
  });
});

document.on('click', '.watchers .user input', function(e, el) {
  e.stop();
  var target = e.element();
  if (!target.checked)
    $('user_all').checked = false;
});
