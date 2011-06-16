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
    this.pages_controller = new Controllers.PagesController({app: this});
  };

  AppController.index = function () {
    var threads = Teambox.collections.threads;

    Views.Sidebar.highlightSidebar('activity_link');
    $('view_title').update('Recent activity');
    $('content').update((new Teambox.Views.Activities({collection: threads})).render().el);
    $('content').insert({bottom: '<a href="#" class="button" id="activity_paginate_link"><span>Show more</span></a>'});
    $('activity_paginate_link').observe('click', threads.fetchNextPage.bind(threads));
  };

  // exports
  Teambox.Controllers.AppController = Controllers.Bootstrap.extend(AppController);

  document.on("dom:loaded", function () {
    Teambox.controllers.application = new Teambox.Controllers.AppController();
  });

}());

