(function  () {

  var Pages = {
    model: Teambox.Models.Page
  };

  Pages.parse = function (response) {
    return _.parseFromAPI(response);
  };

  Pages.url = function () {
    return "/api/1/pages";
  };

  // exports
  Teambox.Collections.Pages = Teambox.Collections.Base.extend(Pages);

}());
