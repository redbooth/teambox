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

  ProjectsController.projects_show = function (permalink) {
    var project = collections.projects.getByPermalink(permalink)
      , threads = Teambox.helpers.projects.filterActivitiesByProject(project.id, Teambox.collections.threads);

    Views.Sidebar.highlightSidebar('project_' + permalink + '_activities');
    $('view_title').update(project.get('name') + ' - Recent activity');
    $('content').update((new Teambox.Views.Activities({collection: threads})).render().el);
  };

  ProjectsController.task_lists = function (permalink) {
    var tasks = collections.tasks.filteredByProject(permalink)
      , project = collections.projects.getByPermalink(permalink)
      , task_lists = project.get('task_lists').setTasks(tasks)
      , view = new Views.TaskLists({collection: task_lists, project: project});

    Teambox.Views.Sidebar.highlightSidebar('project_' + project + '_task_lists');

    $('content').update(view.render().el);

    view.makeAllSortable();

    $('view_title').update(view.title);
  };

  // exports
  Teambox.Controllers.ProjectsController = Teambox.Controllers.BaseController.extend(ProjectsController);

}());
