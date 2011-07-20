// Remove task from sidebar if it's not assigned to me anymore
document.on('ajax:success', ".thread[data-class='task'] form", function(e, form) {
  var status = form.down("select[name='task[status]']").getValue();
  var person = form.down("select[name='task[assigned_id]']").getValue();

  // my_projects contains a list of my Person models, we look them up to see if it's me
  var is_assigned_to_me = (status == 1) && my_projects[person];
  var task = $('my_task_'+form.up('.thread').readAttribute('data-id'));

  if(task) {
    is_assigned_to_me ? task.show() : task.hide()
  }
})
