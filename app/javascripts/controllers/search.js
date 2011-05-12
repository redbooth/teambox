Teambox.Controllers.SearchController = Backbone.Controller.extend({
  routes: {
    '/search/:terms'     : 'search'
  },

  search: function(terms) {
    Teambox.search_view.getResults(terms);
  }
});

_.extend(Teambox.Controllers.SearchController.prototype, Teambox.Views.Utility);
