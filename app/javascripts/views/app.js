// This View holds the frontend application logic

Teambox.Views.App = Backbone.View.extend({

  // Bind to the document's body, with the existing DOM
  el: $(document.body),

  // This method is called to initialize the app
  initialize: function() {
    // Fetch all data we're going to need
    // Uses the Loader class, which updates the progress bar
    Teambox.my_user.fetch({ success: Loader.loaded('user') });
    Teambox.my_tasks.fetch({ success: Loader.loaded('tasks') });
    Teambox.my_threads.fetch({ success: Loader.loaded('activities') });
    Teambox.my_projects.fetch({ success: Loader.loaded('projects') });
  }

});
