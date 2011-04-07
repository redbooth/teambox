Teambox.Controllers.AppController = Backbone.Controller.extend({
  routes: {
    '!/': 'index',
    '!/all_tasks': 'all_tasks',
    '!/my_tasks': 'my_tasks'
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
