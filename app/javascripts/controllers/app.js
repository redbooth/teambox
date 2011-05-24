(function () {

  var Views = Teambox.Views
    , Controllers = Teambox.Controllers
    , views = Teambox.views;

  Teambox.Controllers.AppController = Controllers.Bootstrap.extend({
    routes: {
      '/'                  : 'index',
      '/today'             : 'today',
      '/my_tasks'          : 'my_tasks',
      '/all_tasks'         : 'all_tasks'
    },
    initialize: function (options) {
      Controllers.Bootstrap.prototype.initialize.call(this, options);

      this.projects_controller = new Controllers.ProjectsController({app: this});
      this.users_controller = new Controllers.UsersController({app: this});
      this.tasks_controller = new Controllers.TasksController({app: this});
      this.conversations_controller = new Controllers.ConversationsController({app: this});
      this.search_controller = new Controllers.SearchController({app: this});
      this.pages_controller = new Controllers.PagesController({app: this});
    },

    index: function () {
      Views.Sidebar.highlightSidebar('activity_link');
      views.activities.render();
    },

    today: function () {
      Views.Sidebar.highlightSidebar('today_link');
      views.today_tasks.render();
    },

    my_tasks: function () {
      Views.Sidebar.highlightSidebar('my_tasks_link');
      views.my_tasks.render();
    },

    all_tasks: function () {
      Views.Sidebar.highlightSidebar('all_tasks_link');
      views.all_tasks.render();
    }
  });

  document.on("dom:loaded", function () {
    Teambox.controllers.application = new Teambox.Controllers.AppController();
  });

}());
