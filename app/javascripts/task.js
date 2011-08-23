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

document.on('ajax:success', '.task_header + form.edit_task', function(e, form) {
  var name = form.down('input[name="task[name]"]').getValue()
  form.up('.content').select('.task_header h2, .task .thread_title a.task').invoke('update', name)

  hideEditTaskFormAndShowHeader(form)
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
        if (!select.descendants().any() && typeof I18n == "object") {
          select.insert(new Element('option').insert(I18n.translations.comments['new'].assigned_to_nobody))
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
  },

  classesForListed: function(task) {
    var classes = []
    var due_date = task.due_on ? new Date(Date.parse(task.due_on)) : null
    var now = new Date()
    if (due_date) {
      if (due_date.is_today())
        classes.push('due_today')
      if (due_date.is_tomorrow())
        classes.push('due_tomorrow')
      if (due_date.is_within(now.add_weeks(1)))
        classes.push('due_week')
      if (due_date.is_within(now.add_weeks(2)))
        classes.push('due_2weeks')
      if (due_date.is_within(now.add_weeks(3)))
        classes.push('due_3weeks')
      if (due_date.is_within(now.add_months(1)))
        classes.push('due_month')
      if (due_date - ((new Date()).beginning_of_day()) < 0)
        classes.push('overdue')
    }
    if (!task.due_on)
      classes.push('unassigned_date')
    classes.push('status_' + Task.statusName(task))
    if (task.status != 1) // !open?
      classes.push('status_notopen')
    if (task.due_on && !(task.status == 3 || task.status == 4)) // !(rejected||resolved)
      classes.push('due_on')
    if (!(task.status == 3 || task.status == 4))
      classes.push((task.assigned_id != 0) ? 'assigned' : 'unassigned')
    if (task.assigned)
      classes.push('user_' + task.assigned.user_id)
    if (task.is_private)
      classes.push('private')
    return classes.join(' ')
  },

  nameForAssigned: function(task) {
    if (!task.assigned)
      return ''
    return I18n.t(I18n.translations.common.format_name_short, {
      first_name: task.assigned.user.first_name, last_name: task.assigned.user.last_name,
      first_name_first_character: task.assigned.user.first_name.substr(0,1),
      last_name_first_character: task.assigned.user.last_name.substr(0,1)
    }).escapeHTML()
  },

  linkToNameForAssigned: function(task) {
    if (!task.assigned)
      return ''
    return '<a href="/users/' + task.assigned.user.username + '">' + Task.nameForAssigned(task) + '</a>';
  },

  fullNameForAssigned: function(task) {
    if (!task.assigned)
      return ''
    return I18n.t(I18n.translations.common.format_name, {
      first_name: task.assigned.user.first_name, last_name: task.assigned.user.last_name
    }).escapeHTML()
  },

  dateForDueOn: function(task) {
    var due_date = task.due_on ? new Date(Date.parse(task.due_on)) : null
    if (!due_date)
      return ''
    if (due_date - (new Date().beginning_of_day()) < 0 && due_date.days_since() <= 5)
      return I18n.t(I18n.translations.tasks.overdue, {days: due_date.days_since()})
    else {
      if (due_date.is_today())
        return I18n.t(I18n.translations.tasks.due_on.today)
      else if (due_date.is_tomorrow())
        return I18n.t(I18n.translations.tasks.due_on.tomorrow)
      else
        return due_date.strftime('%b %D')
    }
  },

  statusName: function(task) {
    return ['new', 'open', 'hold', 'resolved', 'rejected'][task.status]
  },

  renderMyTask: function(task) {
    return Mustache.to_html(Templates.tasks.my_task, {
      task_id: task.id,
      task_classes: Task.classesForListed(task),
      task_url: '/projects/' + task.project_id + '/tasks/' + task.id,
      task_name: task.name,
      task_due: Task.dateForDueOn(task)
    })
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
    my_user.stats.tasks++;
    document.fire("stats:update");
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

// main task update callback
document.on('task:updated', function(e, doc){
  var task_data = e.memo
  var is_assigned_to_me = (task_data.status == 1) && task_data.assigned && task_data.assigned.user_id == my_user.id

  // update task counter
  var counter = $$('.task_counter[data-task-id='+ task_data.id +']').first()
  if (counter) counter.update(parseInt(counter.innerHTML) + 1)

  // task in task list
  var task = $('task_' + task_data.id)
  var task_classes = Task.classesForListed(task_data)
  if (task) {
    var due_on = task.down('.assigned_date')
    var assigned_user = task.down('.assigned_user')
    due_on.update(Task.dateForDueOn(task_data))
    assigned_user.update(Task.linkToNameForAssigned(task_data))
    task.writeAttribute('class', 'task expanded ' + task_classes)
    task.writeAttribute('data-user-id', task_data.user_id)
    task.writeAttribute('data-watcher-ids', (task_data.watchers||[]).join(','))
  }

  // task in thread
  task = $('thread_task_' + task_data.id)
  if (task) {
    var summary = task.down('.task_summary')
    summary.writeAttribute('class', 'task_summary ' + task_classes)
    summary.down('.task_status').writeAttribute('class', 'task_status task_status_' + Task.statusName(task_data))
    summary.down('.task_status').update(Task.statusName(task_data))
    summary.down('.assigned_date').update(Task.dateForDueOn(task_data))
    summary.down('.assigned_to').update(task_data.assigned ? I18n.t(I18n.translations.tasks.assigned.assigned_to, {user: Task.fullNameForAssigned(task_data)}) : '')
    
    // sync attributes
    task.writeAttribute('data-user-id', task_data.user_id)
    task.writeAttribute('data-watcher-ids', (task_data.watchers||[]).join(','))
    var counter = task.down('.comment_header').down('.comment_count').down()
    if (counter) counter.update(parseInt(counter.innerHTML) + 1)
  }

  // task in my tasks sidebar
  var task_sidebar = $('my_task_' + task_data.id);
  if (task_sidebar) {
    if (is_assigned_to_me) {
      task_sidebar.writeAttribute('class', 'el task ' + task_classes)
      task_sidebar.down('.due_on').update(Task.dateForDueOn(task_data))
    } else {
      task_sidebar.remove()
    }
  } else if (is_assigned_to_me) {
    $('my_tasks').next().insert({top:Task.renderMyTask(task_data)})
  }

  $('open_my_tasks').update($('my_tasks').next().getElementsBySelector('.el.task').length)

  // task in sidebar (viewing single task)
  task_sidebar = $('task_list_task_' + task_data.id);
  if (task_sidebar) {
    task_sidebar.writeAttribute('class', 'task ' + task_classes)
    task_sidebar.down('.due_on').update(Task.dateForDueOn(task_data))
  }
})

document.on('ajax:success', 'form.edit_task', function(e, form) {
  var task_data = e.memo.headerJSON
  if (!task_data)
    return

  document.fire('task:updated', task_data)

  // Update form and task count
  var assigned_user_id = task_data.assigned ? task_data.assigned.user_id : 0
  var is_assigned_to_me = (task_data.status == 1) && assigned_user_id == my_user.id

  form.writeAttribute('data-mine', String(Boolean(is_assigned_to_me)))
})


document.on('ajax:failure', 'form.new_task.app_form', function(e, form) {
  var message = $H(e.memo.responseJSON)
	message.keys().each( function(k) {
		field = form.down('#task_'+k)
		if (field) field.parentNode.insertOrUpdate('span.error', message.get(k))
	})
})

document.on('ajax:before', 'form.new_task.app_form', function(e, form) {
  form.select('span.error').invoke('remove')
})

document.on('ajax:success', '.task_list form.new_task', function(e, form) {
  var person = form['task[assigned_id]'].getValue()
  var task_count = Number($('open_my_tasks').innerHTML)
  var is_assigned_to_me = my_projects[person]

  var response = e.memo.responseText
  resetCommentsForm(form)

  if (is_assigned_to_me) {
    task_count += 1
    $('open_my_tasks').update(task_count)
  }

  Form.reset(form).focusFirstElement().up('.task_list').down('.tasks').insert(response)
})

