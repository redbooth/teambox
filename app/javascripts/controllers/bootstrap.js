(function () {
  var views = Teambox.views
    , models = Teambox.models
    , collections = Teambox.collections;

  Teambox.Controllers.Bootstrap = Backbone.Controller.extend({
    config: {}

  , initialize: function (options) {
      var self = this,
          _loader = Teambox.modules.Loader(function () {
            // Set the new root url
            if (window.location.hash === '') {
              window.location.hash = '#!/';
            }

            self.notificationsController = new Teambox.Controllers.Notifications(self);
            self.build();
            Backbone.history.start();
          });

      Backbone.Controller.prototype.initialize.call(this, options);

      // Initialize models and collections
      models.user          = this.my_user     = new Teambox.Models.User();
      collections.people                      = new Teambox.Collections.People();
      collections.tasks    = this.my_tasks    = new Teambox.Collections.Tasks();
      collections.threads  = this.my_threads  = new Teambox.Collections.Threads();
      collections.projects = this.my_projects = new Teambox.Collections.Projects();

      // Fetch all data we're going to need
      // Uses the Loader class, which updates the progress bar
      models.user.fetch({success: _loader.load('user')});
      collections.tasks.fetch({success: _loader.load('tasks')});
      collections.threads.fetch({success: _loader.load('activities')});

      _loader.total++; // this is hackish, but the loader is a little bit too dumb
      collections.projects.fetch({success: function (projects) {
        var done = 0;
        _.each(projects.models, function (project, i) {
          _loader.total++;
          (new Teambox.Collections.People({project_id: project.id})).fetch({
            success: function (people) {
              _loader.loaded++;
              projects.models[i].set({people: people});

              try {
                collections.people.add(people.models, {silent: true});
              } catch (e) {
                // may try to add same people twice
              }

              done += 1;
              if (done === projects.length) {
                console.log(collections.people);
                _loader.loaded++;
                _loader.load('projects')();
              }
            }
          });
        });
      }});
    }

  , build: function () {
      // Initialize views
      views.projects_view   = new Teambox.Views.Projects({ app: this, collection: this.my_projects });
      views.search_view     = new Teambox.Views.Search({ app: this, el: $('search') });

      views.sidebar     = new Teambox.Views.Sidebar({ el: $('column') });
    }
  , setPushSessionId: function (push_session_id) {
      this.push_session_id = push_session_id;
    }
  });

}());

