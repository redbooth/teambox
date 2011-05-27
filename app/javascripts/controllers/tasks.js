(function () {
  var TasksController = { routes: { '/projects/:project/tasks'     : 'index'
                                  , '/projects/:project/tasks/:id' : 'show' }}

    , collections = Teambox.collections;

  TasksController.index = function () {
    $('content').update('index task');
  };

  TasksController['new'] = function () {
    $('content').update('new task');
  };

  TasksController.show = function (project, id) {
    var task = collections.tasks.get(id);
    $('content').update((new Teambox.Views.Thread({ model: task })).render().el);
    Teambox.Views.Sidebar.highlightSidebar('project_' + project + '_task_lists');
  };

  //exports
  Teambox.Controllers.TasksController = Teambox.Controllers.BaseController.extend(TasksController);
}());
