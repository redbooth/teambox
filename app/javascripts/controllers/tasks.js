(function () {
  var TasksController = { routes: { '/projects/:project/tasks'     : 'index'
                                  , '/projects/:project/tasks/:id' : 'show'
                                  , '/today'                       : 'today'
                                  , '/my_tasks'                    : 'my_tasks'
                                  , '/all_tasks'                   : 'all_tasks'
                                  }
                        }

    , Views = Teambox.Views
    , collections = Teambox.collections;

  TasksController.index = function () {
    $('content').update('index task');
  };

  TasksController['new'] = function () {
    $('content').update('new task');
  };

  TasksController.show = function (project, id) {
    var task = collections.tasks.get(id);
    $('content').update((new Views.Thread({model: new Teambox.Models.Thread(task.attributes)})).render().el);
    Teambox.Views.Sidebar.highlightSidebar('project_' + project + '_task_lists');
  };

  TasksController.today = function () {
    var view = new Views.TodayTasks({collection: collections.tasks});

    Views.Sidebar.highlightSidebar('today_link');
    $('content').update(view.render().el);
    $('view_title').update(view.title);
  };

  TasksController.my_tasks = function () {
    var view = new Views.MyTasks({collection: collections.tasks});

    Views.Sidebar.highlightSidebar('my_tasks_link');
    $('content').update(view.render().el);
    $('view_title').update(view.title);
  };

  TasksController.all_tasks = function () {
    var view = new Views.AllTasks({collection: collections.tasks})
      , filters = new Views.Filters({ task_list: view
                                    , filters: { name: null
                                               , assigned: null
                                               , due_date: null
                                               , status: null }});

    Views.Sidebar.highlightSidebar('all_tasks_link');

    $('content')
      .update(view.render().el)
      .insert({top: filters.render().el});
    $('view_title').update(view.title);
  };

  //exports
  Teambox.Controllers.TasksController = Teambox.Controllers.BaseController.extend(TasksController);
}());
