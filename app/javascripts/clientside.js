Teambox = {
  Models: {},
  Collections: {},
  Controllers: {},
  Views: {}
};

Teambox.Controllers.AppController = Backbone.Controller.extend({
  routes: {
    '': 'index',
    'all_tasks': 'all_tasks',
    'my_tasks': 'my_tasks'
  },
  index: function() {
    // Super hack!!! FIXME TODO BROKEN HORRIBLECODE
    $('content').update('<div id="activities"></div>');
    TeamboxClient.fetchAndRenderActivities();
  },
  all_tasks: function() {
    Teambox.my_tasks_view.render();
  },
  my_tasks: function() {
    Teambox.my_tasks_view.render();
  }
});

Teambox.Models.Task = Backbone.Model.extend({
  initialize: function() {
  },
  render: function() {
  },
  url: function() {
    return "/api/1/tasks/" + this.get('id');
  }
});

Teambox.Collections.Tasks = Backbone.Collection.extend({
  model: Teambox.Models.Task,
  parse: function(response) {
    return response.objects;
  },
  url: function() {
    return "/api/1/tasks";
  }
});

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
    $('content').update(Mustache.to_html(Templates.tasks.index, {tasks: this.collection.toJSON()}));
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

Teambox.Models.User = Backbone.Model.extend({
  initialize: function () {
    this.bind('change:username', this.onRename);
  },
  onRename: function () {
    this.render();
    return this;
  },
  username_template: "<a href='/users/{{username}}'>{{username}}</a>",
  render: function() {
    var html = Mustache.to_html(this.username_template, this.toJSON());
    $('username').update(html);

    return this;
  },
  url: function() {
    return "/api/1/account";
  }
});

document.on("dom:loaded", function() {
  // Fetch current user
  Teambox.my_user = new Teambox.Models.User();
  Teambox.my_user.fetch();

  // Fetch my tasks
  Teambox.my_tasks = new Teambox.Collections.Tasks();
  Teambox.my_tasks.fetch();

  // Print my tasks
  Teambox.my_tasks_counter_view = new Teambox.Views.MyTasksCounter({
    collection: Teambox.my_tasks
  });
  Teambox.my_tasks_view = new Teambox.Views.MyTasks({
    collection: Teambox.my_tasks
  });

  app = new Teambox.Controllers.AppController();
  Backbone.history.start();
});

