var TaskList = {
  in_sort: false,
  
  sortableChange: function(draggable) {
    this.currentDraggable = draggable
  },
  
  sortableUpdate: function() {
    task_list_ids = this.currentDraggable.up().select('.task_list').collect(
    function(task_list) {
        return task_list.readAttribute('data-task-list-id')
    }).join(',')

    new Ajax.Request('/projects/' + current_project + '/task_lists/reorder', {
      method: 'put',
      parameters: { task_list_ids: task_list_ids }
    })
  }.debounce(100),

  makeSortable: function() {
    TaskList.in_sort = true;
    Sortable.create('task_lists', {
      constraint:'vertical',
      handle:'img.drag',
      tag:'div',
      only:'task_list_container',
      onChange: TaskList.sortableChange.bind(TaskList),
      onUpdate: TaskList.sortableUpdate.bind(TaskList)
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

  // Replaces new list (or inserts if applicable)
  replaceList: function(id, content, archived) {
    var existing = $(id);
    if (!id)
      TaskList.insertList(id,content,archived);
    else
      existing.replace(content);
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
    Filter.updateCounts();
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

  reloadList: function(el, part, callback) {
    var url = el.readAttribute('action_url');
    var on_index = el.hasClassName('index_task_lists');
    if (!url)
      return;
    url = url.indexOf('?') >= 0 ? (url + '&part=' + part) : (url + '?part=' + part);
    if (on_index)
      url = url + '&on_index=1';
    new Ajax.Request(url, {
      asynchronous: true,
      evalScripts: true,
      method: 'get',
      onComplete: function(request) {
        callback(request);
        Task.make_all_sortable();
      }
    });
  },

  setTitle: function(element, visible) {
    var title = $(element.readAttribute('toggleformbase') + 'title');
    if (title == null)
      return;
    if (visible)
      title.show();
    else
      title.hide();
  },

  setReorder: function(active) {
    $$('.task_list_container').invoke(active ? 'addClassName' : 'removeClassName', 'reordering')

    if (active) {
      $('reorder_task_lists_link').swapVisibility('done_reordering_task_lists_link')
      Filter.showAllTaskLists()
      $$('.filters').invoke('hide')
      TaskList.makeSortable()
    } else {
      $('done_reordering_task_lists_link').swapVisibility('reorder_task_lists_link')
      Filter.updateFilters()
      $$('.filters').invoke('show')
      TaskList.destroySortable()
    }
  },
  
  updatePrimer: function() {
    var primer = $('primer');
    if (primer && $$('.task_list').length == 0)
      primer.show();
    else if (primer)
      primer.hide();
  },
  populateTaskListSelect: function(project_id, select, callback) {

    new Ajax.Request('/api/1/projects/' + project_id + '/task_lists.json', {
      method:'get',
      requestHeaders: {Accept: 'application/json'},
      onSuccess: function(transport){
        var json = transport.responseText.evalJSON(true);
        select.options.length = 0;
        json.objects.each(function(taskList) {
          select.options.add(new Option(taskList.name, taskList.id));
        });

        if (!select.childElements().any(function(option) {return option.text == 'Inbox';})) {
          select.options.add(new Option("Inbox", ''));
        }
      },
      onFailure: function() {
        alert('Error loading page! Please reload.');
        if (callback) {
          callback();
        }
      }
    });
  }
};

document.on('click', '#reorder_task_lists_link', function(e, element){
  e.stop()
  TaskList.setReorder(true);
});

document.on('click', '#done_reordering_task_lists_link', function(e, element){
  e.stop()
  TaskList.setReorder(false);
});

document.observe('toggleform:loaded:edit_task_list', function(evt) {
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

document.observe('toggleform:loaded:new_task_list', function(evt) {
  // Reload sort
  if (TaskList.in_sort) {
	setTimeout(function(){
      TaskList.setReorder(false);	
      TaskList.setReorder(true);
    }, 0);
  }
  setTimeout(function(){
    Task.make_all_sortable();
    TaskList.updatePrimer();
    TaskList.saveColumn();
  }, 0);
});

document.observe('toggleform:cancel:edit_task_list', function(evt) {
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
  TaskList.updateForm(el, el.readAttribute('href'));
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
  ToggleForm.toggleElement(el); // edit form on task list show
});

document.on('click', 'a.edit_task_list_link', function(e, el) {
  e.stop();
  ToggleForm.toggleElement(el); // edit form on task list show
});

document.on('click', 'a.unarchive_task_list_link', function(e, el) {
  e.stop();
  TaskList.unarchive(el, el.readAttribute('action_url'));
});

// creating new tasks
document.on('click', '.task_list .new_task a[href$="/new"]', function(e, link) {
  if (!e.isMiddleClick()) {
    e.stop()
    link.hide().next('form').forceShow().focusFirstElement()
  }
})

var hideTaskFormAndShowLink = function(form) {
  Form.reset(form).hide().previous('a[href$="/new"]').show()
}

document.on('click', '.task_list .new_task form a[href="#cancel"]', function(e, link) {
  e.stop()
  hideTaskFormAndShowLink(link.up('form'))
})

document.on('keyup', '.task_list .new_task form', function(e, form) {
  if (e.keyCode == Event.KEY_ESC) hideTaskFormAndShowLink(form)
})

document.on('ajax:success', '.task_list form.new_task', function(e, form) {
  var person = form['task[assigned_id]'].getValue();
  var task_count = Number($('open_my_tasks').innerHTML)
  var is_assigned_to_me = my_projects[person]

  if (e.memo.transport) {
    var response = e.memo.responseText
  } else {
    var response = e.memo.responseText.unescapeHTML()
    resetCommentsForm(form)
  }

  if (is_assigned_to_me) {
    task_count += 1
    $('open_my_tasks').update(task_count)
  }
  Form.reset(form).focusFirstElement().up('.task_list').down('.tasks').insert(response)
})
