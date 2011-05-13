Teambox.Controllers.TasksController = Teambox.Controllers.BaseController.extend({
  routes: {
    '/projects/:project/tasks'             : 'tasks_index',
    '/projects/:project/tasks/:id'         : 'tasks_show'
  },

  // Tasks
  tasks_new: function() {
    $('content').update( 'new task' );
  },

  tasks_show: function() {
    $('content').update( 'show task' );
  }
});
