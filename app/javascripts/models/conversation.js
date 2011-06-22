(function () {
  var Conversation = {};

  Conversation.initialize = function (options) {
  };

 /* Returns the class name
  *
  * @return {String}
  */
  Conversation.className = function () {
    return 'Conversation';
  };

  Conversation.isConversation = function(){return true;}

  /* return the `convert_to_task` url
   *
   * @return {String}
   */
  Conversation.convertToTaskUrl = function () {
    return '/api/1/projects/' + this.get('project_id') + '/conversations/' + this.get('id') + '/convert_to_task';
  };

  /* return the `comments` url
   *
   * @return {String}
   */
  Conversation.commentsUrl = function () {
    return '/api/1/projects/' + this.get('project_id') + '/conversations/' + this.get('id') + '/comments';
  };

  /* return the resource url
   *
   * @return {String}
   */
  Conversation.url = function () {
    return "/api/1/conversations/" + this.get('id');
  };

  /* parses the incoming data from the API
   *
   * @return {Object}
   */
  Conversation.parse = function (response) {
    return _.parseFromAPI(response)[0];
  };

  /* Check if the model has been loaded fully
   *
   * @return {Boolean}
   */
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
    var url = this.convertToTaskUrl()
      , a = new Ajax.Request(url, { method: 'post'
                                  , parameters: parameters
                                  , requestHeaders: {Accept: 'application/json'}
                                  , onSuccess: onSuccess
                                  , onFailure: onFailure});
  };

  // exports
  Teambox.Models.Conversation = Teambox.Models.Base.extend(Conversation);
}());
