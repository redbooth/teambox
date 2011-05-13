Teambox.Controllers.ProjectsController = Teambox.Controllers.BaseController.extend({

  routes: {
    '/projects'                            : 'projects_index',
    '/projects/new'                        : 'projects_new',
    '/projects/:id'                        : 'projects_show',
    '/projects/:project/people'            : 'people_index',
    '/projects/:project/settings'          : 'project_edit'
  },

  projects_index: function() {
    Teambox.Views.Sidebar.highlightSidebar('projects_link');
    this.app.projects_view.render();
  },

  projects_new: function() {
    Teambox.Views.Sidebar.highlightSidebar('new_project_link');
    $('content').update( 'new project' );
  },

  projects_show: function() {
    $('content').update( 'show project' );
  }

});

