Teambox.Controllers.AppController = Backbone.Controller.extend({
  routes: {
    '!/': 'index',
    '!/all_tasks': 'all_tasks',
    '!/my_tasks': 'my_tasks'
  },
  index: function() {
    Teambox.activities_view.render();
  },
  all_tasks: function() {
    Teambox.all_tasks_view.render();
  },
  my_tasks: function() {
    Teambox.my_tasks_view.render();
  }
});
