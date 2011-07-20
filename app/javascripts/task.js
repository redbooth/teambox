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

document.on('keyup', '.task_header + .edit_task', function(e, form) {
  if (e.keyCode == Event.KEY_ESC) hideEditTaskFormAndShowHeader(form)
})

document.on('ajax:failure', 'form.new_task.app_form', function(e, form) {
  var message = $H(e.memo.responseJSON)
	message.each( function(error) {
		form.down('div.text_field').insertOrUpdate('p.error', error.value)
	})
})

document.on('ajax:success', '.task_header + form.edit_task', function(e, form) {
  var name = form.down('input[name="task[name]"]').getValue()
  form.up('.content').select('.task_header h2, .task .thread_title a.task').invoke('update', name)

  hideEditTaskFormAndShowHeader(form)
})

// update task counter
document.on('ajax:success', 'form.edit_task', function(e, form) {
  var task_data = e.memo.headerJSON
  var counter = $$('.task_counter[data-task-id='+ task_data.id +']').first()
  if (counter) counter.update(parseInt(counter.innerHTML) + 1)
})

document.on('click', '.date_picker', function(e, element) {
  new CalendarDateSelect(element.down('input'), element.down('span'), {
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
    var taskId = this.currentDraggable.readAttribute('data-task-id'),
        taskList = this.currentDraggable.up('.task_list')
        taskListId = taskList.readAttribute('data-task-list-id')

    taskIds = taskList.select('.tasks .task').collect(
      function(task) {
          return task.readAttribute('data-task-id')
      }).join(',')

    new Ajax.Request('/projects/' + current_project + '/tasks/' + taskId + '/reorder', {
      method: 'put',
      parameters: { task_list_id: taskListId, task_ids: taskIds }
    })
  }.debounce(100),

  makeSortable: function(task_id, all_task_ids) {
    Sortable.create(task_id, {
      constraint: 'vertical',
      containment: all_task_ids,
      // format: /.*task_(\d+)_task_task/,
      handle: 'task_drag',
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
  },

  insertAssignableUsers: function() {
    if (typeof _people == "object") {
      $$('form.new_comment.edit_task .task_actions select#task_assigned_id, form.new_comment.edit_conversation .conversation_actions select#conversation_assigned_id, #new_task select#task_assigned_id').each(function(select) {
        var project_id = select.up('form').readAttribute('data-project-id')
        if (!select.descendants().any()) {
          select.insert(new Element('option').insert(task_unassigned))
        }
        if (typeof _people[project_id] == "object") {
          _people[project_id].each(function(person) {
            if (!select.select('[value=' + person[0] + ']').any()) {
              var option = new Element('option', { 'value': person[0] }).insert(person[2])
              if (select.readAttribute('data-assigned') == person[0]) option.selected = true
              select.insert(option)
            }
          })
        }
      })
    }
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

document.on('ajax:success', '.new_task form', function(e){
  setTimeout(function(){
    Task.highlight_my_tasks();
    Task.make_all_sortable();
    TaskList.saveColumn();
    TaskList.updatePage('column', TaskList.restoreColumn);
  }, 0);
})

// Enable task sort on load and highlight my tasks
document.observe('dom:loaded', function(e) {
  if(typeof(my_user) == "undefined") return

  if ($$('.tasks').length > 0 && !$('tasks_for_all_projects')) {
    Task.make_all_sortable()
  }
  Task.highlight_my_tasks()
  Filter.populatePeopleForTaskFilter()
  Filter.updateCounts(false)
  Filter.updateFilters()
  Task.insertAssignableUsers()
});

document.on('ajax:success', 'form.edit_task', function(e, form) {
  var person = form['task[assigned_id]'].value
  var status = form['task[status]'] && form['task[status]'].value
  var task = form.up('.thread')
  var task_count = Number($('open_my_tasks').innerHTML),
      is_assigned_to_me = (status == 1) && my_projects[person]
      was_assigned_to_me = form.readAttribute('data-mine')

  form.writeAttribute('data-mine', String(Boolean(is_assigned_to_me)))

  if (is_assigned_to_me && !(was_assigned_to_me=='true')){
      task_count += 1
  }
  if ((was_assigned_to_me=='true') && !is_assigned_to_me){
      task_count -= 1
  }
  $('open_my_tasks').update(task_count)

})

