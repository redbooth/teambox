(function () {
  var views = Teambox.views
    , models = Teambox.models
    , collections = Teambox.collections;

  Teambox.Controllers.Bootstrap = Backbone.Controller.extend({
    config: {},

    initialize: function (options) {
      var self = this,
          _loader = Teambox.modules.Loader(function () {
            // Set the new root url
            if (window.location.hash === '') {
              window.location.hash = '#!/';
            }

            self.build();
            Backbone.history.start();
          });

      Backbone.Controller.prototype.initialize.call(this, options);

      // Initialize models and collections
      models.user          = this.my_user     = new Teambox.Models.User();
      collections.tasks    = this.my_tasks    = new Teambox.Collections.Tasks();
      collections.threads  = this.my_threads  = new Teambox.Collections.Threads();
      collections.projects = this.my_projects = new Teambox.Collections.Projects();

      // Fetch all data we're going to need
      // Uses the Loader class, which updates the progress bar
      this.my_user.fetch({ success: _loader.load('user') });
      this.my_tasks.fetch({ success: _loader.load('tasks') });
      this.my_threads.fetch({ success: _loader.load('activities') });
      this.my_projects.fetch({ success: _loader.load('projects') });
    },

    build: function () {
      // Initialize views
      this.projects_view   = new Teambox.Views.Projects({ app: this, collection: this.my_projects });
      this.search_view     = new Teambox.Views.Search({ app: this, el: $('search') });

      views.activities  = new Teambox.Views.Activities({ collection: this.my_threads });
      views.today_tasks = new Teambox.Views.TodayTasks({ collection: this.my_tasks });
      views.my_tasks    = new Teambox.Views.MyTasks({ collection: this.my_tasks });
      views.all_tasks   = new Teambox.Views.AllTasks({ collection: this.my_tasks });
      views.sidebar     = new Teambox.Views.Sidebar({ el: $('column') });
    }
  });

}());
