(function () {
  var Conversation = {};

  Conversation.initialize = function (options) {
  };

  Conversation.convert_to_task_url = function () {
    return '/api/1/projects/' + this.get('project_id') + '/conversations/' + this.get('id') + '/convert_to_task';
  };

  Conversation.url = function () {
    return "/api/1/conversations/" + this.get('id');
  };

  Conversation.parse = function (response) {
    return _.parseFromAPI(response)[0];
  };

  // Check if the model has been loaded fully
  Conversation.isLoaded = function () {
    // If it doesn't have a project_id, for example, it's not loaded
    return !!this.getAttributes().project_id;
  };

  /* Calls to the convert_to_task API
   *
   * @param {Object} parameters
   * @param {Function} onSuccess
   * @param {Function} onFailure
   */
  Conversation.convertToTask = function (parameters, onSuccess, onFailure) {
    var url = this.convert_to_task_url()
      , a = new Ajax.Request(url, { method: 'post'
                                  , parameters: parameters
                                  , requestHeaders: {Accept: 'application/json'}
                                  , onSuccess: onSuccess
                                  , onFailure: onFailure});
  };

  // exports
  Teambox.Models.Conversation = Teambox.Models.Base.extend(Conversation);
}());
