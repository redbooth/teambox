// For Projects#index: Load task in main view with AJAX
document.on('click', '.my_tasks_listing .task a', function(e, el) {
  if (e.isMiddleClick()) return
  e.stop()

  var task = el.up('.task')

  task.down('.left_arrow_icon').hide()
  task.down('.loading_icon').show()
  
  new Ajax.Request(task.down('a.name').readAttribute('href')+"?nolayout=1", {
    method: "get",
    onSuccess: function(r) {
      $('content').update(r.responseText)
      format_posted_date()
      Task.insertAssignableUsers()
      pushHistoryState(el.readAttribute('href'))
      $('back_to_overview').show()
    },
    onComplete: function() {
      task.down('.left_arrow_icon').show()
      task.down('.loading_icon').hide()
    }
  })

})

// Remove task from sidebar if it's not assigned to me anymore
document.on('ajax:success', ".thread[data-class='task'] form", function(e, form) {
  var status = form.down("select[name='task[status]']").getValue()
  var person = form.down("select[name='task[assigned_id]']").getValue()

  // my_projects contains a list of my Person models, we look them up to see if it's me
  var is_assigned_to_me = (status == 1) && my_projects[person]
  var task = $('my_tasks_'+form.up('.thread').readAttribute('data-id'))

  if(task) {
    is_assigned_to_me ? task.show() : task.hide()
  }
})

