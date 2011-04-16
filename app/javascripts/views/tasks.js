Teambox.Views.Today = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this, 'render');
  },

  template: Handlebars.compile("<h2>What you need to do today</h2>"+Templates.tasks.index),
  primer_template: Handlebars.compile(Templates.primers.today),

  render: function() {
    var tasks = this.collection.today();

    if (tasks.length > 0) {
      $('content').update( this.template() );
      tasks.each( function(task) {
        // WARNING: Am I creating a view each time the task is rendered? This is bad
        // Maybe we should keep a reference to the view in the model
        var view = new Teambox.Views.Task({ model: task });
        $$('.task_list .tasks')[0].insert({ bottom: view.render().el });
      });
    } else {
      $('content').update( this.primer_template() );
    }
  }

});

Teambox.Views.MyTasks = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this, 'render');
  },

  template: Handlebars.compile(Templates.tasks.index),

  render: function() {
    $('content').update( this.template() );

    this.collection.mine().each( function(task) {
      // WARNING: Am I creating a view each time the task is rendered? This is bad
      // Maybe we should keep a reference to the view in the model
      var view = new Teambox.Views.Task({ model: task });
      $$('.task_list .tasks')[0].insert({ bottom: view.render().el });
    });
  }

});

Teambox.Views.AllTasks = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this, 'render');
  },

  template: Handlebars.compile(Templates.tasks.index),

  render: function() {
    $('content').update( this.template() );

    this.collection.each( function(task) {
      // WARNING: Am I creating a view each time the task is rendered? This is bad
      // Maybe we should keep a reference to the view in the model
      var view = new Teambox.Views.Task({ model: task });
      //this.$("#todo-list").append(view.render().el);
      $$('.task_list .tasks')[0].insert({ bottom: view.render().el });
    });
  }

});
