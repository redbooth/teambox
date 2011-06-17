(function () {

  var Page = {};

  /* Get the public url
   *
   * @return {String}
   */
  Page.publicUrl = function () {
    return '/projects/' + this.get('project_id') + '/pages/' + this.id;
  };

  /* Get the API url
   *
   * @return {String}
   */
  Page.url = function () {
    return '/api/1' + this.publicUrl();
  };

  Page.parse = function (response) {
    return _.parseFromAPI(response.objects);
  };

  // exports
  Teambox.Models.Page = Teambox.Models.Base.extend(Page);
}());
