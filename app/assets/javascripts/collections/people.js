(function  () {

  var People = {
    model: Teambox.Models.Person
  };

  People.initialize = function (models, options) {
    options = options || {};
    this.project_id = options.project_id;
  };

  People.parse = function (response) {
    return _.parseFromAPI(response);
  };

  People.url = function () {
    return '/api/1/projects/' + this.project_id + '/people.json';
  };

  // exports
  Teambox.Collections.People = Teambox.Collections.Base.extend(People);

}());
