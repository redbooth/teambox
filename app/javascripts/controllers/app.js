Teambox.Controllers.AppController = Teambox.Controllers.Bootstrap.extend({
  routes: {
    '/'                  : 'index',
    '/today'             : 'today',
    '/my_tasks'          : 'my_tasks',
    '/all_tasks'         : 'all_tasks'
  },
  initialize: function(options) {
    Teambox.Controllers.Bootstrap.prototype.initialize.call(this, options);

    this.projects_controller = new Teambox.Controllers.ProjectsController({app: this});
    this.users_controller = new Teambox.Controllers.UsersController({app: this});
    this.tasks_controller = new Teambox.Controllers.TasksController({app: this});
    this.conversations_controller = new Teambox.Controllers.ConversationsController({app: this});
    this.search_controller = new Teambox.Controllers.SearchController({app: this});
    this.pages_controller = new Teambox.Controllers.PagesController({app: this});
  },

  index: function() {
    Teambox.Views.Sidebar.highlightSidebar('activity_link');
    this.activities_view.render();
  },

  today: function() {
    Teambox.Views.Sidebar.highlightSidebar('today_link');
    this.today_view.render();
  },

  my_tasks: function() {
    Teambox.Views.Sidebar.highlightSidebar('my_tasks_link');
    this.my_tasks_view.render();
  },

  all_tasks: function() {
    Teambox.Views.Sidebar.highlightSidebar('all_tasks_link');
    this.all_tasks_view.render();
  }
});
