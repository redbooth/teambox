(function () {

  var Upload = {};

  /* Get the public url
   *
   * @return {String}
   */
  Upload.publicUrl = function () {
    return '/projects/' + this.get('project_id') + '/uploads/' + this.id;
  };

  Upload.parse = function (response) {
    // Link slot objects from references
    return _.parseFromAPI(response);
  };

  Upload.isImage = function() {
    return false;
  };

  /**
   * Check if the model has been loaded fully
   *
   * @return {Boolean}
   */
  Upload.isLoaded = function () {
    // If it doesn't have a project_id, for example, it's not loaded
    return !!this.getAttributes().project_id;
  };


  // exports
  Teambox.Models.Upload = Teambox.Models.Base.extend(Upload);
}());
