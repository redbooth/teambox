Teambox.Controllers.ProjectsController = Backbone.Controller.extend({
  routes: {
    '/projects'                            : 'projects_index',
    '/projects/new'                        : 'projects_new',
    '/projects/:id'                        : 'projects_show',
    '/projects/:project/people'            : 'people_index',
    '/projects/:project/settings'          : 'project_edit'
  },

  projects_index: function() {
    this.highlightSidebar('projects_link');
    Teambox.projects_view.render();
  },

  projects_new: function() {
    this.highlightSidebar('new_project_link');
    $('content').update( 'new project' );
  },

  projects_show: function() {
    $('content').update( 'show project' );
  }

});

_.extend(Teambox.Controllers.ProjectsController.prototype, Teambox.Views.Utility);
