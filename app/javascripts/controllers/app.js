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
    var threads = Teambox.collections.threads
      , show_more = '<a href="#" class="button" id="activity_paginate_link"><span>Show more</span></a>';

    Views.Sidebar.highlightSidebar('activity_link');
    $('view_title').update('Recent activity');
    $('content').update((new Teambox.Views.Activities({collection: threads})).render().el);
    $('content').insert({bottom: show_more});

    // TODO: move this inside the view
    $('activity_paginate_link').observe('click', function onShowMore(event) {
      var el = event.element();
      Element.replace('activity_paginate_link', '<img id="activity_paginate_link" src="/images/loading.gif" alt="loading..." />');

      threads.fetchNextPage(function (collection, response) {
        Element.replace('activity_paginate_link', show_more);
        $('activity_paginate_link').observe('click', onShowMore);
        if (response.objects.length <= 50) {
          el.hide();
        }
      });
    });
  };

  // exports
  Teambox.Controllers.AppController = Controllers.Bootstrap.extend(AppController);

  document.on("dom:loaded", function () {
    Teambox.controllers.application = new Teambox.Controllers.AppController();
  });

}());
