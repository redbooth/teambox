document.on('click', '.task_header .text_actions a[href$="/edit"]', function(e, link) {
  if (!e.isMiddleClick()) {
    e.stop()
    link.up('.task_header').hide().next('form.edit_task').forceShow().focusFirstElement()
  }
})

var hideEditTaskFormAndShowHeader = function(form) {
  Form.reset(form).hide().previous('.task_header').show()
}

document.on('click', '.task_header + .edit_task a[href="#cancel"]', function(e, link) {
  e.stop()
  hideEditTaskFormAndShowHeader(link.up('.edit_task'))
})

document.on('keyup', '.task_header + .edit_task:has(a[href="#cancel"])', function(e, form) {
  if (e.keyCode == Event.KEY_ESC) hideEditTaskFormAndShowHeader(form)
})

document.on('ajax:success', '.task_header + form.edit_task', function(e, form) {
  var name = form.down('input[name="task[name]"]').getValue(),
      dueDate = form.down('span.localized_date').innerHTML

  form.up('.content').select('.task_header h2, .task .thread_title a.task').invoke('update', name)
  $('column').down('.due_on').update(dueDate)
  
  hideEditTaskFormAndShowHeader(form)
})

// update task counter
document.on('ajax:success', 'form.edit_task', function(e, form) {
	var task_data = e.memo.headerJSON
	counter = $$('.task_counter[data-task-id='+ task_data.id +']').first()
  counter.update(parseInt(counter.innerHTML) + 1)
})

document.on('click', '.date_picker img', function(e, element) {
  new CalendarDateSelect(element.next('input'), element.next('span'), {
    buttons: true,
    popup: 'force',
    time: false,
    year_range: [2008, 2020]
  })
})

Task = {
  
  sortableChange: function(draggable) {
    this.currentDraggable = draggable
  },
  
  sortableUpdate: function() {
    var taskID = this.currentDraggable.id.split('_').last(),
        taskList = this.currentDraggable.up('.task_list'),
        position = taskList.select('.tasks .task').indexOf(this.currentDraggable) + 1,
        ids = taskList.id.match(/project_(\d+)_task_list_(\d+)/)
    
    new Ajax.Request('/projects/' + ids[1] + '/tasks/' + taskID + '/reorder', {
      method: 'put',
      parameters: { task_list_id: ids[2], position: position }
    })
  }.debounce(100),

  makeSortable: function(task_id, all_task_ids) {
    Sortable.create(task_id, {
      constraint: 'vertical',
      containment: all_task_ids,
      // format: /.*task_(\d+)_task_task/,
      handle: 'img.task_drag',
      dropOnEmpty: true,
      // that makes the task disappear when it leaves its original task list
      // only:'task',
      tag: 'div',
      onChange: Task.sortableChange.bind(Task),
      onUpdate: Task.sortableUpdate.bind(Task)
    })
  },

  make_all_sortable: function() {
    var task_div_ids = $$(".tasks.open").map(function(task_div){
      return task_div.identify();
    })
    task_div_ids.each(function(task_div_id){
      Task.makeSortable(task_div_id, task_div_ids);
    })
  },

  highlight_my_tasks: function() {
    $$(".task.user_"+my_user.id).invoke('addClassName', 'mine')
  },

  insertTask: function(task_list_id, archived, task_id, html) {
    var container = archived ? $(task_list_id + '_the_closed_tasks') : $(task_list_id + '_the_main_tasks');
    container.insert({bottom: html});
    new Effect.Highlight(task_id, { duration: 3 });
    TaskList.updateList(task_list_id);
  },

  removeTask: function(task_list_id, task_id) {
    $(task_id).remove();
    TaskList.updateList(task_list_id);
  },

  replaceTasks: function(task_list_id, archived, html) {
    var container = archived ? $(task_list_id + '_the_closed_tasks') : $(task_list_id + '_the_main_tasks');
    container.innerHTML = html;
    TaskList.updateList(task_list_id);
  }
}

document.on('click', 'a.show_archived_tasks_link', function(e, el) {
  e.stop();
  var task_container_id = el.up('.task_list').id;
  var task_list_id = $(task_container_id).up().id;
  el.hide();
  el.up().down('.loading').show();
  TaskList.reloadList($(task_container_id), 'tasks', function(req){
    el.up().remove();
    new Effect.BlindDown(task_list_id + '_the_closed_tasks', {duration:0.3});
  });
});

document.observe('jenny:loaded:new_task', function(evt) {
  setTimeout(function(){
    Task.make_all_sortable();
    TaskList.saveColumn();
    TaskList.updatePage('column', TaskList.restoreColumn);
  }, 0);
});

document.observe('jenny:loaded:edit_task', function(evt) {
  setTimeout(function(){
    Task.make_all_sortable();
    TaskList.updatePage('column', TaskList.restoreColumn);
  }, 0);
});

document.observe('jenny:cancel:edit_task', function(evt) {
  $('show_task').down(".task_header").show();
});

// Enable task sort on load and highlight my tasks
document.observe('dom:loaded', function(e) {
  if ($$('.tasks').length > 0) Task.make_all_sortable();
  Task.highlight_my_tasks();
  Filter.updateCounts(false);
  Filter.updateFilters();
});
