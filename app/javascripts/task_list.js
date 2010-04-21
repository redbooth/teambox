var TaskList = {
  in_sort: false,

  // Sortable functions

  makeSortable: function() {
    TaskList.in_sort = true;
    Sortable.create('task_lists', {
      constraint:'vertical',
      handle:'img.drag',
      tag:'div',
      only:'task_list_container',
      onUpdate: function(){
        new Ajax.Request($('task_lists').readAttribute("reorder_url"), {
          asynchronous: true,
          evalScripts: true,
          parameters: Sortable.serialize('task_lists')
        });
      }
    });
  },
  destroySortable: function() {
    TaskList.in_sort = false;
    Sortable.destroy('task_lists');
  },

  // Inserts new list
  insertList: function(id, content, archived) {
    if (archived)
      $('task_lists').insert({bottom: content});
    else
      $('task_lists').insert({top: content});
    new Effect.Highlight(id, {duration:3});
  },

  // Removes an existing list
  removeList: function(id) {
    var el = $(id);
    if (el)
    {
      el.remove();
    }
  },

  // Updates task list state
  updateList: function(id) {
    // ...
    var list = $(id);
    if (!list)
      return;
    
    var open = $(id + '_the_main_tasks');
    var archived = $(id + '_the_closed_tasks');
    var open_count = open.childElements().length;
    var archived_count = archived.childElements().length;
    var link = $(id + '_archive_link');
    if (open_count == 0 && archived_count > 0)
      link.show();
    else
      link.hide();
  },

  setArchived: function(id, value) {
    var el = $(id);
    if (el) {
      if (value)
        el.addClassName('archived');
      else
        el.removeClassName('archived');
    }
  },

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
  },

  updateForm: function(element, url) {
    new Ajax.Request(url, {
      method: 'get',
      asynchronous: true,
      evalScripts: true,
      onLoading: function() {
        Actions.setLoading(element, true);
      },
      onSuccess: function(response){
        Actions.setActions(element, false);
        Actions.setLoading(element, false);
      },
      onFailure: function(response){	
        Actions.setLoading(element, false);
      }
    });	
  },

  resolveAndArchive: function(element, url) {
    new Ajax.Request(url, {
      method: 'put',
      asynchronous: true,
      evalScripts: true,
      onLoading: function() {
        Actions.setLoading(element, true);
      },
      onSuccess: function(response){
        TaskList.saveColumn();
        TaskList.updatePage('column', TaskList.restoreColumn);
      },
      onFailure: function(response){
        Actions.setLoading(element, false);
      }
    });
  },

  unarchive: function(element, url) {
    new Ajax.Request(url, {
      method: 'put',
      asynchronous: true,
      evalScripts: true,
      parameters:'task_list[archived]=false',
      onLoading: function() {
        //Actions.setLoading(element, true);
      },
      onSuccess: function(response){
        TaskList.saveColumn();
        TaskList.updatePage('column', TaskList.restoreColumn);
      },
      onFailure: function(response){
        //Actions.setLoading(element, false);
      }
    });
  },

  saveColumn: function() {
    var saved = {};
    if ($('filter_assigned'))
    {
      saved.filter_assigned = $('filter_assigned').selectedIndex;
      saved.filter_due_date = $('filter_due_date').selectedIndex;
    }
    TaskList.saved = saved;
  },

  restoreColumn: function() {
    var saved = TaskList.saved;
    if (saved) {
      if (saved.filter_assigned)
      {
        $('filter_assigned').selectedIndex = saved.filter_assigned;
        $('filter_due_date').selectedIndex = saved.filter_due_date;
      }
    }
  },

  updatePage: function(part, callback) {
    var el = $(document.body);
    var url = el.readAttribute('reload_url');
    if (!url)
      return;
    url = url.indexOf('?') >= 0 ? (url + '&part=' + part) : (url + '?part=' + part);
    new Ajax.Request(url, {
      asynchronous: true,
      evalScripts: true,
      method: 'get',
      onComplete: callback
    });
  },

  setTitle: function(element, visible) {
    var title = $(element.readAttribute('jennybase') + 'title');
    if (title == null)
      return;
    if (visible)
      title.show();
    else
      title.hide();
  },

  setReorder: function(active) {
    $$('.task_list_container').each(function(value) { 
      if(active)
        value.addClassName('reordering');
      else
        value.removeClassName('reordering');
    });

    if (active)
    {
      $('reorder_task_lists_link').hide();
      $('done_reordering_task_lists_link').show();
      Filter.showAllTaskLists();
      TaskList.makeSortable();
    }
    else
    {
      $('reorder_task_lists_link').show();
      $('done_reordering_task_lists_link').hide();
      Filter.updateFilters();
      TaskList.destroySortable();
    }
  },
  
  updatePrimer: function() {
    var primer = $('primer');
    if (primer && $$('.task_list').length == 0)
      primer.show();
    else if (primer)
      primer.hide();
  }
};

document.on('click', '#reorder_task_lists_link', function(e, element){
  TaskList.setReorder(true);
});

document.on('click', '#done_reordering_task_lists_link', function(e, element){
  TaskList.setReorder(false);
});

document.observe('jenny:loaded:edit_task_list', function(evt) {
  // Reload sort
  if (TaskList.in_sort) {
    setTimeout(function(){
      TaskList.setReorder(false);	
      TaskList.setReorder(true);
    }, 0);
  }
  TaskList.saveColumn();
  TaskList.updatePage('column', TaskList.restoreColumn);
});

document.observe('jenny:loaded:new_task_list', function(evt) {
  // Reload sort
  if (TaskList.in_sort) {
	setTimeout(function(){
      TaskList.setReorder(false);	
      TaskList.setReorder(true);
    }, 0);
  }
  setTimeout(function(){
    TaskList.updatePrimer();
    TaskList.saveColumn();
    TaskList.updatePage('column', TaskList.restoreColumn);
  }, 0);
});

document.observe('jenny:cancel:edit_task_list', function(evt) {
  // Only do this on the index
  if (evt.memo.form.up('.task_list_container'))
  {
    TaskList.setTitle(evt.memo.form, true);
    Actions.setActions(evt.memo.form, true);
  }
  else
  {
    evt.memo.form.up().down(".task_header").show();
  }
});

// update action
document.on('click', 'a.taskListUpdate', function(e, el) {
  e.stop();
  TaskList.updateForm(el, el.readAttribute('action_url'));
});

// delete action
document.on('click', 'a.taskListDelete', function(e, el) {
  e.stop();
  if (confirm(el.readAttribute('aconfirm')))
    TaskList.destroy(el, el.readAttribute('action_url'));
});

// resolve action
document.on('click', 'a.taskListResolve', function(e, el) {
  e.stop();
  if (confirm(el.readAttribute('aconfirm')))
    TaskList.resolveAndArchive(el, el.readAttribute('action_url'));
});

document.on('click', 'a.create_first_task_list_link', function(e, el) {
  e.stop();
  Jenny.toggleElement(el); // edit form on task list show
});

document.on('click', 'a.edit_task_list_link', function(e, el) {
  e.stop();
  Jenny.toggleElement(el); // edit form on task list show
});

document.on('click', 'a.unarchive_task_list_link', function(e, el) {
  e.stop();
  TaskList.unarchive(el, el.readAttribute('action_url'));
});

