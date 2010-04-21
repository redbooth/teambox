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