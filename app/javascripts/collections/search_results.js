(function  () {

  var SearchResults = {};

  SearchResults.initialize = function (models, options) {
    options = options || {};

    this.project_id = options.project_id;
    this.query = options.query;
  };

  /* parse the response and convert each element
   * to the correct model
   *
   * @param {Response} response
   * @return {Array}
   */
  SearchResults.parse = function (response) {
    return _.map(_.parseFromAPI(response), function (el) {
      return new Teambox.Models[el.type](el);
    });
  };

  SearchResults.url = function () {
    var url = '/api/1';

    if (this.project_id) {
      url += '/' + this.project_id;
    }

    return url + '/search?q=' + this.query;
  };

  // exports
  Teambox.Collections.SearchResults = Teambox.Collections.Base.extend(SearchResults);

}());
