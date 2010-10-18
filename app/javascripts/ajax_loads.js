// For Projects#index: Load task in main view with AJAX
document.on('click', '.my_tasks_listing .task a', function(e, el) {
  if (e.isMiddleClick()) return
  e.stop()
  
  el.up('.task').down('.left_arrow_icon').hide()
  el.up('.task').down('.loading_icon').show()
  
  new Ajax.Request(el.readAttribute('href')+".frag", {
    method: "get",
    onSuccess: function(r) {
      $('content').update(r.responseText)
      format_posted_date()
      $('back_to_overview').show()
    },
    onComplete: function() {
      el.up('.task').down('.left_arrow_icon').show()
      el.up('.task').down('.loading_icon').hide()
    }
  })

})

// Remove task from sidebar if it's not assigned to me anymore
document.on('ajax:success', '.task form', function(e, form) {
  var status = form.down("select[name='task[status]']").getValue()
  var person = form.down("select[name='task[assigned_id]']").getValue()

  // my_projects contains a list of my Person models, we look them up to see if it's me
  var is_assigned_to_me = (status == 1) && my_projects[person]
  var task = $('my_tasks_'+form.up('.thread').readAttribute('data-id'))

  if(task) {
    if(is_assigned_to_me) { task.show() } else { task.hide() }
  }
})

// TODO: If i assign something to myself, it should be added to my task list

// Load activities on main view using AJAX
document.on('click', '#back_to_overview', function(e, el) {
  if (e.isMiddleClick()) return
  e.stop()

  $('content').update("<div class='loading_icon'> </div>")

  new Ajax.Request(el.readAttribute('href')+".frag", {
    method: "get",
    onSuccess: function(r) {
      $('content').update(r.responseText)
      format_posted_date()
      $('back_to_overview').hide()
    }
  })
})