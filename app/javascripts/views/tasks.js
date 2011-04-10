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
      var view = new Teambox.Views.TaskView({ model: task });
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
      var view = new Teambox.Views.TaskView({ model: task });
      //this.$("#todo-list").append(view.render().el);
      $$('.task_list .tasks')[0].insert({ bottom: view.render().el });
    });

  }
});

Teambox.Views.TaskView = Backbone.View.extend({

  tagName: "div",
  //className: "task", FIXME: should use backbone's classname, not handlebar template's one
  template: Handlebars.compile(Templates.partials.task),

  events: {
    "click a.name": "expandComments",
    "click a.edit": "editTitle"
  },

  initialize: function() {
    _.bindAll(this, "render");
    this.model.bind('change', this.render);
  },

  render: function() {
    $(this.el).update(
      this.template(this.model.toJSON())
    );
    return this;
  },

  // Expand/collapse task comment threads inline
  expandComments: function(evt) {
    var task = $(this.el);

    var thread_block = task.down('.thread');
    if (task.hasClassName('expanded')) {
      var e1 = new Effect.BlindUp(thread_block, {duration: 0.3});
      var e2 = new Effect.Fade(task.down('.expanded_actions'), {duration: 0.3});
    } else {
      var e3 = new Effect.BlindDown(thread_block, {duration: 0.3});
      var e4 = new Effect.Appear(task.down('.expanded_actions'), {duration: 0.3});
      Date.format_posted_dates();
      Task.insertAssignableUsers();
    }
    task.toggleClassName('expanded');
    return false;
  },

  // Edit task's title inline
  editTitle: function(evt) {
    $(this.el).select('a.name, form.edit_title').invoke('toggle');
    return false;
  }
});
