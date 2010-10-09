var Actions = {
  setActions: function(element, visible) {
    var actions = element.up('.task_list_container, .comment').down('.actions_menu');
    if (actions == null)
      return;
    if (visible)
      actions.show();
    else
      actions.hide();
  },

  setLoading: function(element, loading) {
    var actions = element.up('.task_list_container, .comment').down('.actions_menu');
    if (actions == null)
      return;
    if (loading)
    {
      actions.addClassName('loading');
      actions.down('span.loading').show();
      actions.down('span.actiondate').hide();
    }
    else
    {
      actions.removeClassName('loading');
      actions.down('span.loading').hide();
      actions.down('span.actiondate').show();	
    }
  }
};

document.on('mouseover', '.comment .actions_menu', function(e, actions_menu) {
  var comment = actions_menu.up('.comment')
  
  // My own comments: I can modify them, a later filter will ensure that only for 15 minutes
  if(comment.readAttribute('data-user') == my_user.id) {
    actions_menu.down('.edit').forceShow()
  }

  // Projects where I'm admin: I can destroy comments at any time
  var projects_i_admin = $H(my_projects).select( function(e){ return(e[1].role == 3) } ).collect( function(e) { return e[0] } )
  if(projects_i_admin.include(comment.readAttribute('data-project'))) {
    actions_menu.down('.edit').forceShow()
    actions_menu.down('.delete').forceShow()
  }

  // Disable editing comments 15 minutes after posting them
  var now = new Date()
  var timestamp = comment.readAttribute('data-editable-before'),
      editableBefore = new Date(parseInt(timestamp))
  if (now >= editableBefore) {
    link = actions_menu.down('a.edit')
    if(link) {
      var message = link.readAttribute('data-uneditable-message')
      link.replace(new Element('span').update(message).addClassName('edit'))
    }
  }
})
