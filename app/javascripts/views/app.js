// This View holds the frontend application logic

Teambox.Views.App = Backbone.View.extend({

  // Bind to the document's body, with the existing DOM
  el: $(document.body),

  // This method is called to initialize the app
  initialize: function() {
    _.bindAll(this, 'renderTaskCounter');

    // bind only to change
    Teambox.my_tasks.bind('all', this.renderTaskCounter);

    // Fetch all data we're going to need
    // Uses the Loader class, which updates the progress bar
    Teambox.my_user.fetch({ success: Loader.loaded('user') });
    Teambox.my_tasks.fetch({ success: Loader.loaded('tasks') });
    Teambox.my_threads.fetch({ success: Loader.loaded('activities') });
  },

  // Refresh dynamic elements
  render: function() {
    this.renderTaskCounter();
  },

  // Updates my tasks' counter
  renderTaskCounter: function() {
    $$("#my_tasks_link span, #today span").invoke('remove');

    var mine = Teambox.my_tasks.mine();
    var today = Teambox.my_tasks.today();
    var late = Teambox.my_tasks.late();

    if (mine) {
      $("my_tasks_link").insert({ bottom: "<span>"+mine.length+"</span>" });
    }
    if (today) {
      $("today_link").insert({ bottom: "<span>"+today.length+"</span>" });
      if (Teambox.my_tasks.late()) {
        $$("#today_link span")[0].addClassName('red');
      }
    }
  }

});
