(function () {

  var Views = Teambox.Views
    , Controllers = Teambox.Controllers
    , views = Teambox.views
    , AppController = {routes: { '/' : 'index'}};

  AppController.initialize = function (options) {
    Controllers.Bootstrap.prototype.initialize.call(this, options);

    this.projects_controller = new Controllers.ProjectsController({app: this});
    this.users_controller = new Controllers.UsersController({app: this});
    this.tasks_controller = new Controllers.TasksController({app: this});
    this.conversations_controller = new Controllers.ConversationsController({app: this});
    this.search_controller = new Controllers.SearchController({app: this});
    this.chat_controller = new Controllers.ChatController({app: this});
    this.pages_controller = new Controllers.PagesController({app: this});
    this.welcome_controller = new Controllers.WelcomeController({app: this});
  };

  AppController.index = function () {
    Backbone.history.saveLocation('#!/welcome');
  };

  // exports
  Teambox.Controllers.AppController = Controllers.Bootstrap.extend(AppController);

  document.on("dom:loaded", function () {
    Teambox.controllers.application = new Teambox.Controllers.AppController();
  });

}());
