Teambox = {
  Models: {},
  Collections: {},
  Controllers: {},
  Views: {},
  init: function() {
    //Start application once everything has loaded.
    Loader.init(function() {
      // Set the new root url
      if (window.location.hash === '') {
        window.location.hash = '#!/';
      }

      Teambox.application = new Teambox.Controllers.AppController();
      Backbone.history.start();
    });

    // Initialize models and collections
    Teambox.my_user = new Teambox.Models.User();
    Teambox.my_tasks = new Teambox.Collections.Tasks();
    Teambox.my_threads = new Teambox.Collections.Threads();
    Teambox.my_projects = new Teambox.Collections.Projects();

    // Initialize views
    Teambox.activities_view = new Teambox.Views.Activities({ collection: Teambox.my_threads });
    Teambox.today_view = new Teambox.Views.Tasks({ collection: Teambox.my_tasks, tasks_filter: 'today' });
    Teambox.my_tasks_view = new Teambox.Views.Tasks({ collection: Teambox.my_tasks, tasks_filter: 'mine' });
    Teambox.all_tasks_view = new Teambox.Views.Tasks({ collection: Teambox.my_tasks });
    Teambox.projects_view = new Teambox.Views.Projects({ collection: Teambox.my_projects });
    Teambox.search_view = new Teambox.Views.Search({ el: $('search') });
    Teambox.sidebar_view = new Teambox.Views.Sidebar({ el: $('column') });

    // Initialize the app (will fetch the data)
    Teambox.app_view = new Teambox.Views.App();
  }
};

document.on("dom:loaded", function() {
  Teambox.init();
});
