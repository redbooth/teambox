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
      models.user.fetch({success: _loader.load('user')});
      collections.tasks.fetch({success: _loader.load('tasks')});
      collections.threads.fetch({success: _loader.load('activities')});
      collections.pages.fetch({success: _loader.load('pages')});

      _loader.total += 2; // this is hackish, but the loader is a little bit too dumb
      collections.projects.fetch({success: function (projects) {
        var task_list_done = 0, people_done = 0, conversation_done = 0;
        _.each(projects.models, function (project, i) {
          var collection;
          _loader.total += 2;

          // preload task_lists
          collection = new Teambox.Collections.TaskLists([], {project_id: project.id})
          projects.models[i].set({task_lists:collection});
          collection.fetch({
            success: function (task_lists) {
              _loader.loaded++;

              try {
                collections.tasks_lists.add(task_lists.models, {silent: true});
              } catch (e) {
                // may try to add same task_list twice
              }

              task_list_done += 1;
              if (task_list_done === projects.length) {
                _loader.loaded++;
                _loader.load('projects')();
              }
            }
          });

          // preload conversations
          collection = new Teambox.Collections.Conversations([], {project_id: project.id});
          projects.models[i].set({conversations:collection});
          collection.fetch({
            success: function (conversations) {
              _loader.loaded++;

              try {
                collections.conversations.add(conversations.models, {silent: true});
              } catch (e) {
                // may try to add same task_list twice
              }

              conversation_done += 1;
              if (conversation_done === projects.length) {
                _loader.loaded++;
                _loader.load('projects')();
              }
            }
          });

          // preload people
          collection = new Teambox.Collections.People([], {project_id: project.id});
          projects.models[i].set({people:collection});
          collection.fetch({
            success: function (people) {
              _loader.loaded++;

              try {
                collections.people.add(people.models, {silent: true});
              } catch (e) {
                // may try to add same people twice
              }

              people_done += 1;
              if (people_done === projects.length) {
                _loader.loaded++;
                _loader.load('projects')();
              }
            }
          });
        });
      }});
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
