(function () {
  var views = Teambox.views
    , models = Teambox.models
    , collections = Teambox.collections;

  Teambox.Controllers.Bootstrap = Backbone.Controller.extend({
    config: {}
  , windowed_auth_requests: {}
  , initialize: function (options) {
      var self = this,
          _loader = Teambox.modules.Loader(function () {
            // Set the new root url
            if (window.location.hash === '') {
              window.location.hash = '#!/';
            }

            self.clock = Teambox.modules.Clock;
            self.clock.init(self.clockTick.bind(self));
            self.notificationsController = new Teambox.Controllers.Notifications(self);
            self.build();
            Backbone.history.start();
          }, true);

      Backbone.Controller.prototype.initialize.call(this, options);

      // Initialize models and collections
      models.user          = this.my_user     = new Teambox.Models.User();
      collections.people                      = new Teambox.Collections.People();
      collections.tasks_lists                 = new Teambox.Collections.TaskLists();
      collections.conversations               = new Teambox.Collections.Conversations();
      collections.pages                       = new Teambox.Collections.Pages();
      collections.tasks    = this.my_tasks    = new Teambox.Collections.Tasks();
      collections.threads  = this.my_threads  = new Teambox.Collections.Threads();
      collections.projects = this.my_projects = new Teambox.Collections.Projects();

      this.fetchData({
        user: _loader.load()
      , tasks: _loader.load()
      , threads: _loader.load()
      , projects: _loader.load(this.projectsLoaderCallback(_loader))
      });
    }

    /**
     * Fetch data from server on each clock tick
     * "unless" we're synchronizing (.e.g push is active)
     * "or" we're currently inside a clock tick (fetch)
     *
     * @param {Object} clock
     */
  , clockTick: function (clock) {
      console.log('tick - ' + new Date() + ' - fetching data from server...');

      // Every 4 seconds, interval is doubled unless clock.reset(x) is called.
      // We call fetch on each poll unless we have a valid push connection.
      // Push connect event, disables polling.
      // Push disconnect event, enables polling.
      // Call clock.activity() to reset the timer (so the interval is reset to it's original value)
      // Call clock.synchronise() to disable polling.
      // Call clock.synchronised() to enable polling.
      // You can call clock.tick() whenever you want while not synchronizing

      var self = this
        , _loader = Teambox.modules.Loader(function () {
            console.log('fetchData done! Synchronizing clock!');
            //renable polling after last fetch
            clock.synchronised();
          });

      function log(model_class) {
        return function () {
          console.log('Done fetching ' + model_class + '!');
        };
      }

      this.fetchData({
        user: _loader.load(log('user'))
      , tasks: _loader.load(log('tasks'))
      , threads: _loader.load(log('threads'))
      , projects: _loader.load(self.projectsLoaderCallback(_loader, log))
      });
    }

  , synchroniseClock: function () {
      console.log('Push connection! Synchronizing clock!');
      this.clock.synchronise();
    }

  , dontSynchroniseClock: function () {
      console.log('No push connection! Clock synchronized!');
      this.clock.synchronised();
    }

  , projectsLoaderCallback: function (_loader, log) {
      return function (projects) {
        if (log) log('projects')();
        _.each(projects.models, function (project, i) {
          var collection;

          // preload project >> task_lists
          collection = new Teambox.Collections.TaskLists([], {project_id: project.id});
          projects.models[i].set({task_lists: collection});
          collection.fetch({success: _loader.load(function (task_lists) {
            collections.tasks_lists.add(task_lists.models, {silent: true});
            if (log) log('task_lists')();
          })});

          // preload project >> pages
          collection = new Teambox.Collections.Pages([], {project_id: project.id});
          projects.models[i].set({pages: collection});
          collection.fetch({success: _loader.load(function (pages) {
            collections.pages.add(pages.models, {silent: true});
            if (log) { log('pages')(); }
          })});

          // preload project >> conversations
          collection = new Teambox.Collections.Conversations([], {project_id: project.id});
          projects.models[i].set({conversations: collection});
          collection.fetch({success: _loader.load(function (conversations) {
            collections.conversations.add(conversations.models, {silent: true});
            if (log) { log('conversations')(); }
          })});

          // preload project >> people
          collection = new Teambox.Collections.People([], {project_id: project.id});
          projects.models[i].set({people: collection});
          collection.fetch({success: _loader.load(function (people) {
            try {
              collections.people.add(people.models, {silent: true});
              if (log) { log('people')(); }
            } catch (e) {} // may try to add same task_list twice
          })});
        });
      };
    }

    /**
     * Fetch all data we're going to need
     * Uses the Loader class, which updates the progress bar
     *
     * @param {Object} callbacks
     */
  , fetchData: function (callbacks) {
      models.user.fetch({success: callbacks.user});
      collections.tasks.fetch({success: callbacks.tasks});
      collections.threads.fetch({success: callbacks.threads});
      collections.projects.fetch({success: callbacks.projects});
    }

  , build: function () {
      views.search_view = new Teambox.Views.Search();
      views.sidebar = new Teambox.Views.Sidebar({el: $('column')});

      $$('.header h1')[0].insert({after: views.search_view.render().el});
      views.sidebar.renderTaskCounter();
    }
  , setPushSessionId: function (push_session_id) {
      this.push_session_id = push_session_id;
    }

  , triggerGoogleAuthCallback: function (window_id) {
      var callback = this.windowed_auth_requests[window_id];
      if (callback) {
        callback();
      }
    }
  });

}());
