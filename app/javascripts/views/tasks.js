// This view can be used with three filters.
// Pass the parameter 'tasks_filter' with 'all', 'mine' or 'today'
// to narrow the view to the filtered tasks.
// Default is 'all'.

Teambox.Views.Tasks = Backbone.View.extend({

  initialize: function(options) {
    this.tasks_filter = options.tasks_filter || 'all';
    _.bindAll(this, 'render');
  },

  template: {
    today: Handlebars.compile("<h2>What you need to do today</h2>"+Templates.tasks.index),
    mine: Handlebars.compile(Templates.tasks.index),
    all: Handlebars.compile(Templates.tasks.index)
  },
  primer_template: {
    today: Handlebars.compile(Templates.primers.today),
    mine: Handlebars.compile(Templates.primers.my_tasks),
    all: Handlebars.compile(Templates.primers.all_tasks)
  },

  render: function() {
    var tasks;
    switch (this.tasks_filter) {
      case 'mine'  : tasks = this.collection.mine(); break;
      case 'today' : tasks = this.collection.today(); break;
      default      : tasks = this.collection; break;
    }

    if (tasks.length > 0) {
      $('content').update( this.template[this.tasks_filter]() );
      tasks.each( function(task) {
        // WARNING: Am I creating a view each time the task is rendered? This is bad
        // Maybe we should keep a reference to the view in the model
        var view = new Teambox.Views.Task({ model: task });
        $$('.task_list .tasks')[0].insert({ bottom: view.render().el });
      });
    } else {
      $('content').update( this.primer_template[this.tasks_filter]() );
    }
  }

});
