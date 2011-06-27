(function  () {
  var SearchResults = { className: 'search_results'
                      , template: Teambox.modules.ViewCompiler('search_results.index')
                      };

  SearchResults.events = {
  }

  SearchResults.initialize = function (options) {
    this.model = options.collection;
  };

  /* Updates current el
   *
   * @return self
   */
  SearchResults.render = function () {
    this.el.update(this.template(this.collection));
    return this;
  };

  // exports
  Teambox.Views.SearchResults = Backbone.View.extend(SearchResults);
}());
