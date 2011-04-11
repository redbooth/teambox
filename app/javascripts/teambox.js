Teambox = {
  Models: {},
  Collections: {},
  Controllers: {},
  Views: {},
  init: function() {
    Loader.init();

    // Initialize models and collections
    Teambox.my_user = new Teambox.Models.User();
    Teambox.my_tasks = new Teambox.Collections.Tasks();
    Teambox.my_threads = new Teambox.Collections.Threads();

    // Initialize views
    Teambox.today_view = new Teambox.Views.Today({ collection: Teambox.my_tasks });
    Teambox.my_tasks_view = new Teambox.Views.MyTasks({ collection: Teambox.my_tasks });
    Teambox.all_tasks_view = new Teambox.Views.AllTasks({ collection: Teambox.my_tasks });
    Teambox.activities_view = new Teambox.Views.Activities({ collection: Teambox.my_threads });
    Teambox.search_view = new Teambox.Views.Search({ el: $('search') });

    // Initialize the app (will fetch the data)
    Teambox.app_view = new Teambox.Views.App();

    // Set the new root url
    if (window.location.hash === '') {
      window.location.hash = '#!/';
    }

    app = new Teambox.Controllers.AppController();
    Backbone.history.start();

  }
};
