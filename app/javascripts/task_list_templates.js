TaskListTemplates = {

  renderAll: function(templates) {
    var placeholder = $('task_list_templates')
    templates.each(function(template) {
      var t = TaskListTemplates.render(template)
      placeholder.insert(t)
    })
  },

  render: function(template) {
    return Mustache.to_html(Templates.task_list_templates.template, template)
  },

  generateForm: function(id) {
    if (id) {
      var e = $$('.task_list_templates[data-id=' + id + ']').first()
      template = Object.clone(_task_list_templates.find(function(e) { return e.id == id }))
      template.tasks = template.tasks.clone()
      template.verb = 'put'
      template.action = 'edit'
      template.path = '/organizations/' + template.organization + '/task_list_templates/' + id
    } else {
      var e = $('task_list_templates')
      template = { organization: _task_list_templates_organization, tasks: [] }
      template.verb = 'post'
      template.action = 'new'
      template.path = '/organizations/' + template.organization + '/task_list_templates'
    }
    template.tasks.push({name: '', desc: ''})
    if (e.down('form')) { e.down('form').remove() }
    e.insert({ top: Mustache.to_html(Templates.task_list_templates.form, template) })
    TaskListTemplates.sortableForm()
  },

  addField: function(el) {
    if (!el.down('ul input[name="task_list_template[titles][]"][value=]')) {
      el.down('ul').insert(Mustache.to_html(Templates.task_list_templates.form_task, {} ))
      TaskListTemplates.sortableForm()
    }
  },

  doneEditingName: function(id, template) {
    if (id) {
      var e = $$('.task_list_templates[data-id=' + id + ']').first()
    } else {
      var e = $$('form.new_task_list_template').first()
    }
    _task_list_templates = _task_list_templates.reject(function(e) { return e.id == template.id })
    _task_list_templates.push(template)
    e.replace(TaskListTemplates.render(template))
    TaskListTemplates.sortable()
  },

  sortable: function() {
    Sortable.create('task_list_templates', {
      handle: 'drag',
      tag: 'div',
      onChange: function(el) {
        TaskListTemplates.sendSort()
      }
    })
  },

  sortableForm: function() {
    Sortable.create('template_tasks', {
      handle: 'drag',
      tag: 'li'
    })
  },

  sendSort: function(el) {
    var ids = $$('.task_list_templates').collect(function(e) { return e.readAttribute('data-id') })
    var organization = _task_list_templates_organization
    new Ajax.Request('/organizations/' + organization + '/task_list_templates/reorder', {
      method: 'put',
      parameters: Sortable.serialize('task_list_templates')
    })
  },

  loadPage: function() {
    if ($('task_list_templates')) {
      $('task_list_templates').update('')
      TaskListTemplates.renderAll(_task_list_templates)
      TaskListTemplates.sortable()
    }
  }
}

document.on('ajax:success', 'form.edit_task_list_template', function(e, form) {
  var id = form.up('.task_list_templates').readAttribute('data-id')
  var response = e.memo.responseJSON
  TaskListTemplates.doneEditingName(id, response)
})

document.on('ajax:success', 'form.new_task_list_template', function(e, form) {
  var response = e.memo.responseJSON
  TaskListTemplates.doneEditingName(null, response)
})

document.on('click', '.task_list_templates .edit_icon', function(e, el) {
  var t = el.up('.task_list_templates')
  TaskListTemplates.generateForm(t.readAttribute('data-id'))
  t.down('.data').hide()
  e.stop()
})

document.on('click', '.task_list_templates .trash_icon', function(e, el) {
  var t = el.up('.task_list_templates')
  var id = t.readAttribute('data-id')
  if (confirm('Sure?')) {
    new Ajax.Request('/organizations/' + _task_list_templates_organization + '/task_list_templates/' + id, { method: 'delete' })
    t.remove()
    _task_list_templates = _task_list_templates.reject(function(e) { return e.id == id })
  }
  e.stop()
})

document.on('click', 'a.new_task_list_template', function(e, el) {
  TaskListTemplates.generateForm()
  e.stop()
})

document.on('click', 'form.new_task_list_template a.cancel, form.edit_task_list_template a.cancel', function(e,el) {
  if (el.up('.task_list_templates')) { el.up('.task_list_templates').down('.data').show() }
  el.up('form').remove()
  e.stop()
})

document.on('keyup', 'form.new_task_list_template ul input[name="task_list_template[titles][]"], form.edit_task_list_template ul input[name="task_list_template[titles][]"]', function(e, el) {
  TaskListTemplates.addField(el.up('form'))
})

