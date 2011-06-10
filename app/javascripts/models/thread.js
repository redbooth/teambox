(function () {

  Teambox.Models.Thread = Teambox.Models.Base.extend({

   /* Returns the class name
    *
    * @return {String}
    */
    className: function () {
      return this.get('type');
    }

    /* Checks if the thread is a Task
     *
     * @return {Boolean}
     */
  , isTask: function () {
      return this.get('type') === 'Task';
    }

    /* Checks if the thread is a Conversation
     *
     * @return {Boolean}
     */
  , isConversation: function () {
      return this.get('type') === 'Conversation';
    }

  , url: function () {
      switch (this.get('type')) {
      case 'Conversation':
        return '/api/1/projects/' + this.get('project_id') + "/conversations/" + this.id;
      case 'Task':
        return '/api/1/projects/' + this.get('project_id') + "/tasks/" + this.id;
      }
    }

  , commentsUrl: function () {
      return this.url() + '/comments';
    }

    /* Parses response and builds an array of comments attached to the thread
     *
     * @param {Response} response
     * @return {Array}
     */
  , parseComments: function (response) {
      var thread_attributes = response.objects
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
        comment_attributes.assigned = assigned_user.user;
      }

      if (project) {
        comment_attributes.project = project;
      }

      return comment_attributes;
    }

  , parse: function (response) {
      if (response.objects) {
        return _.parseFromAPI(response.objects);
      } else {
        return _.parseFromAPI(response)[0];
      }
    }
  });

}());

