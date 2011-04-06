Teambox.Views.MyTasksCounter = Backbone.View.extend({
  initialize: function() {
    _.bindAll(this, 'render');
    this.collection.bind('all', this.render);
  },
  render: function() {
    $$('#my_tasks span').first().update(this.collection.length);
  }
});

Teambox.Views.MyTasks = Backbone.View.extend({
  initialize: function() {
    _.bindAll(this, 'render');
  },
  render: function() {
    // TODO: compile the template just once
    Handlebars.registerHelper('status_name', function() {
      return $w('new open hold resolved rejected')[this.status];
    });
    var template = Handlebars.compile(Templates.tasks.index);
    $('content').update(
      template({ tasks: this.collection.toJSON() })
    );
  }
});

Teambox.Views.TaskView = Backbone.View.extend({
  tagName: "div",
  template: "lol",
  initialize: function() {
    _.bindAll(this, "render");
  },
  render: function() {
    $(this.el).update("wowowow");
    return this;
  }
});
