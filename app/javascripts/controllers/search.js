Teambox.Controllers.SearchController = Teambox.Controllers.BaseController.extend({
  routes: {
    '/search/:terms'     : 'search'
  },

  search: function(terms) {
    this.app.search_view.getResults(terms);
  }
});
