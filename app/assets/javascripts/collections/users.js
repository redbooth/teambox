(function  () {

  var Users = {
    model: Teambox.Models.User
  };

  Users.initialize = function (options) {
  };

  Users.parse = function (response) {
    return _.parseFromAPI(response);
  };

  Users.url = function () {
    return '/api/1/users.json';
  };

  // exports
  Teambox.Collections.Users = Teambox.Collections.Base.extend(Users);

}());
