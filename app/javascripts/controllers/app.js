Teambox.Controllers.AppController = Backbone.Controller.extend({
  routes: {
    '/'                  : 'index',
    '/today'             : 'today',
    '/my_tasks'          : 'my_tasks',
    '/all_tasks'         : 'all_tasks',
    '/search/:terms'     : 'search',
    '/users/:id'         : 'users_show',
    // projects
    '/projects'                            : 'projects_index',
    '/projects/new'                        : 'projects_new',
    '/projects/:id'                        : 'projects_show',
    '/projects/:project/conversations'     : 'conversations_index',
    '/projects/:project/conversations/:id' : 'conversations_show',
    '/projects/:project/tasks'             : 'tasks_index',
    '/projects/:project/tasks/:id'         : 'tasks_show',
    '/projects/:project/pages'             : 'pages_index',
    '/projects/:project/pages/:id'         : 'pages_show',
    '/projects/:project/people'            : 'people_index',
    '/projects/:project/settings'          : 'project_edit'
  },

  // Top level collections

  index: function() {
    this.highlightSidebar('activity_link');
    Teambox.activities_view.render();
  },

  today: function() {
    this.highlightSidebar('today_link');
    Teambox.today_view.render();
  },

  my_tasks: function() {
    this.highlightSidebar('my_tasks_link');
    Teambox.my_tasks_view.render();
  },

  all_tasks: function() {
    this.highlightSidebar('all_tasks_link');
    Teambox.all_tasks_view.render();
  },

  search: function(terms) {
    Teambox.search_view.getResults(terms);
  },

  // Projects

  projects_index: function() {
    this.highlightSidebar('projects_link');
    Teambox.projects_view.render();
  },

  projects_new: function() {
    this.highlightSidebar('new_project_link');
    $('content').update( 'new project' );
  },

  // Conversations

  conversations_new: function() {
    $('content').update( Handlebars.compile(Templates.conversations['new'])() );
  },

  // Display 'loading', fetch the conversation and display it
  conversations_show: function(project, id) {
    var model = new Teambox.Models.Conversation({ id: id });
    var view = new Teambox.Views.Conversation({ model: model });
    view.render();
    model.fetch();
  },

  // Tasks

  tasks_new: function() {
    $('content').update( 'new task' );
  },

  tasks_show: function() {
    $('content').update( 'show task' );
  },

  // Pages

  pages_new: function() {
    $('content').update( 'new page' );
  },

  pages_show: function() {
    $('content').update( 'show page' );
  },

  // Users

  users_show: function() {
    $('content').update( 'show user' );
  },

  // Projects

  projects_show: function() {
    $('content').update( 'show project' );
  },

  // Utility methods

  highlightSidebar: function(id) {
    Teambox.sidebar_view.selectElement($(id), true);
  }
});
