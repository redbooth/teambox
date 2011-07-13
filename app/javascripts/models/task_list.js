(function () {

  var TaskList = {};

  /**
   * Get the public url
   *
   * @return {String}
   */
  TaskList.publicUrl = function () {
    return '/projects/' + this.get('project_id') + '/task_lists/' + this.id;
  };

  /**
   * Get the API url
   *
   * @return {String}
   */
  TaskList.url = function () {
    var base_url = '/api/1';

    if (this.get('project_id')) {
      base_url += '/projects/' + this.get('project_id');
    }

    base_url += '/task_lists';

    if (this.isNew()) {
      return base_url;
    } else {
      return base_url + '/' + encodeURIComponent(this.id);
    }
  };

  /**
   * Get the `archive` API url
   *
   * @return {String}
   */
  TaskList.archiveUrl = function () {
    return this.url() + '/archive';
  };

  /**
   * Calls to the archive API
   *
   * @param {Function} callback
   */
  TaskList.archive = function (callback) {
    var self = this
      , url = this.archiveUrl();

    function onSuccess(transport) {
      self.set({archived: true});
      _.each(self.get('tasks'), function (task) {
        task.set({assigned: null, status: 3});
      });

      // new activities will be fetched
      Teambox.collections.threads.fetch({success: function () {
        callback(null);
      }});
    }

    new Ajax.Request(url, { method: 'PUT'
                          , requestHeaders: {Accept: 'application/json'}
                          , onSuccess: onSuccess
                          , onFailure: function (transport) {
                              callback(Error(transport.status + ': ' + transport.responseText));
                            }
                          });
  };

  // exports
  Teambox.Models.TaskList = Teambox.Models.Base.extend(TaskList);
}());
