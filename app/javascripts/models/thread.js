(function () {

  var Thread = {};

 /* Returns the class name
  *
  * @return {String}
  */
  Thread.className = function () {
    return this.get('type');
  };

  /* Checks if the thread is a Task
   *
   * @return {Boolean}
   */
  Thread.isTask = function () {
    return this.get('type') === 'Task';
  };

  /* Checks if the thread is a Conversation
   *
   * @return {Boolean}
   */
  Thread.isConversation = function () {
    return this.get('type') === 'Conversation';
  };

  /* Get the public url
   *
   * @return {String}
   */
  Thread.publicUrl = function () {
    return '/projects/' + this.get('project_id') + '/' + this.get('type').toLowerCase() + 's/' + this.id;
  };

  /* Get the API url
   *
   * @return {String}
   */
  Thread.url = function () {
    return '/api/1' + this.publicUrl();
  };

  /* Get the comments url
   *
   * @return {String}
   */
  Thread.commentsUrl = function () {
    return this.url() + '/comments';
  };

  /* Parses response and builds an array of comments attached to the thread
   *
   * @param {Response} response
   * @return {Array}
   */
  Thread.parseComments = function (response) {
    var thread_attributes = ( response.objects || response )
      , comment_attributes = _.detect(response.references, function (ref) {
          return thread_attributes.recent_comment_ids[0] === ref.id;
        })
      , assigned_user = _.detect(response.references, function (ref) {
          return ref.type === 'Person' && comment_attributes.assigned_id === ref.id;
        })
      , project = _.detect(response.references, function (ref) {
          return ref.type === 'Project' && comment_attributes.project_id === ref.id;
        });

    if (assigned_user) {
      comment_attributes.assigned = assigned_user;
    }

    if (project) {
      comment_attributes.project = project;
    }

    if (typeof comment_attributes.body_html === 'string') {
      comment_attributes.body_html = comment_attributes.body_html.unescapeHTML();
    }

    return comment_attributes;
  };

  Thread.parse = function (response) {
    if (response.objects) {
      return _.parseFromAPI(response.objects);
    } else {
      return _.parseFromAPI(response);
    }
  };

  // exports
  Teambox.Models.Thread = Teambox.Models.Base.extend(Thread);
}());
