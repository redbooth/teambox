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
      collections.tasks_lists                 = new Teambox.Collections.TaskLists();
      collections.conversations               = new Teambox.Collections.Conversations();
      collections.pages                       = new Teambox.Collections.Pages();
      collections.tasks    = this.my_tasks    = new Teambox.Collections.Tasks();
      collections.threads  = this.my_threads  = new Teambox.Collections.Threads();
      collections.projects = this.my_projects = new Teambox.Collections.Projects();

      // Fetch all data we're going to need
      // Uses the Loader class, which updates the progress bar
      models.user.fetch({success: _loader.load()});
      collections.tasks.fetch({success: _loader.load()});
      collections.threads.fetch({success: _loader.load()});
      collections.pages.fetch({success: _loader.load()});
      collections.projects.fetch({success: _loader.load(function (projects) {
        _.each(projects.models, function (project, i) {
          var collection;

          // preload task_lists
          collection = new Teambox.Collections.TaskLists([], {project_id: project.id});
          projects.models[i].set({task_lists: collection});
          collection.fetch({success: _loader.load(function (task_lists) {
            try {
              collections.tasks_lists.add(task_lists.models, {silent: true});
            } catch (e) {} // may try to add same task_list twice
          })});

          // preload conversations
          collection = new Teambox.Collections.Conversations([], {project_id: project.id});
          projects.models[i].set({conversations: collection});
          collection.fetch({success: _loader.load(function (conversations) {
            try {
              collections.conversations.add(conversations.models, {silent: true});
            } catch (e) {} // may try to add same task_list twice
          })});

          // preload people
          collection = new Teambox.Collections.People([], {project_id: project.id});
          projects.models[i].set({people: collection});
          collection.fetch({success: _loader.load(function (people) {
            try {
              collections.people.add(people.models, {silent: true});
            } catch (e) {} // may try to add same task_list twice
          })});
        });
      })});
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
  });

}());
