(function () {

  var ProjectsController = { routes: { '/projects'                     : 'projects_index'
                                     , '/projects/new'                 : 'projects_new'
                                     , '/projects/:id'                 : 'projects_show'
                                     , '/projects/:project/people'     : 'people_index'
                                     , '/projects/:project/settings'   : 'project_edit'
                                     , '/projects/:project/task_lists' : 'task_lists'
                                     }
                           }
    , Views = Teambox.Views
    , collections = Teambox.collections;

  ProjectsController.projects_index = function () {
    Views.Sidebar.highlightSidebar('projects_link');
    $('content').update((new Views.Projects({collection: collections.projects})).render().el);
  };

  ProjectsController.projects_new = function () {
    Teambox.Views.Sidebar.highlightSidebar('new_project_link');
    $('content').update('new project');
  };

  ProjectsController.projects_show = function () {
    $('content').update('show project');
  };

  ProjectsController.task_lists = function (project) {
    var tasks = collections.tasks.filteredByProject(project)
      , collection = new Teambox.Collections.Tasks(tasks)
      , view = new Views.ProjectTasks({collection: collection})
      , filters = new Views.Filters({ task_list: view
                                    , filters: { name: null
                                               , assigned: null
                                               , due_date: null
                                               , status: null }});

    Teambox.Views.Sidebar.highlightSidebar('project_' + project + '_task_lists');

    $('content')
      .update(view.render().el)
      .insert({top: filters.render().el});

    $('view_title').update(view.title);
  };

  // exports
  Teambox.Controllers.ProjectsController = Teambox.Controllers.BaseController.extend(ProjectsController);

}());
