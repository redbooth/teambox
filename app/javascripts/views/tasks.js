Teambox.Views.MyTasksCounter = Backbone.View.extend({
  initialize: function() {
    _.bindAll(this, 'render');
    this.collection.bind('all', this.render);
  },
  render: function() {
    $$("#my_tasks_link span").invoke('remove');
    $("my_tasks_link").insert({
        bottom: "<span>"+this.collection.length+"</span>"
    });
  }
});

Teambox.Views.MyTasks = Backbone.View.extend({
  initialize: function() {
    _.bindAll(this, 'render');
  },
  render: function() {
    var template = Handlebars.compile(Templates.tasks.index);
    $('content').update(
      template({
        // there's gotta be a better way of filtering collections
        tasks: this.collection.mine().collect( function(t) { return t.attributes; } )
      })
    );
  }
});

Teambox.Views.AllTasks = Backbone.View.extend({
  initialize: function() {
    _.bindAll(this, 'render');
  },
  render: function() {
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
