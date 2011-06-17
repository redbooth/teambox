(function () {

  var SearchController = { routes: { '/search/:query' : 'search'}}
    , Views = Teambox.Views
    , Controllers = Teambox.Controllers
    , views = Teambox.views;

  SearchController.search = function (query) {
    Views.Sidebar.highlightSidebar(null);

    // TODO: add spin
    $('content').update('loading...');

    (new Teambox.Collections.SearchResults({query: query})).fetch({success: function (collection, response) {
      $('content').update((new Teambox.Views.Activities({collection: collection})).render().el);
    }});
  };

  // exports
  Teambox.Controllers.SearchController = Teambox.Controllers.BaseController.extend(SearchController);
}());
