(function () {

  var ProjectsController = Teambox.Controllers.BaseController.extend({

    routes: {
      '/projects'                     : 'projects_index'
    , '/projects/new'                 : 'projects_new'
    , '/projects/:id'                 : 'projects_show'
    , '/projects/:project/people'     : 'people_index'
    , '/projects/:project/settings'   : 'project_edit'
    , '/projects/:project/task_lists' : 'task_lists'
    }

  , projects_index: function () {
      Teambox.Views.Sidebar.highlightSidebar('projects_link');
      this.views.projects_view.render();
    }

  , projects_new: function () {
      Teambox.Views.Sidebar.highlightSidebar('new_project_link');
      $('content').update('new project');
    }

  , projects_show: function () {
      $('content').update('show project');
    }

  , task_lists: function (project) {
      Teambox.Views.Sidebar.highlightSidebar('project_' + project + '_task_lists');
      this.app.today_view.render();
    }

  });

  // exports
  Teambox.Controllers.ProjectsController = ProjectsController;

}());
