Teambox.Controllers.AppController = Backbone.Controller.extend({
  routes: {
    '!/'                : 'index',
    '!/all_tasks'       : 'all_tasks',
    '!/my_tasks'        : 'my_tasks',
    '!/today'           : 'today',
    '!/search/:terms'   : 'search'
  },
  index: function() {
    Teambox.activities_view.render();
  },
  today: function() {
    Teambox.today_view.render();
  },
  my_tasks: function() {
    Teambox.my_tasks_view.render();
  },
  all_tasks: function() {
    Teambox.all_tasks_view.render();
  },
  search: function(terms) {
    Teambox.search_view.getResults(terms);
  }
});
