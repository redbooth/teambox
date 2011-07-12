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

  // exports
  Teambox.Models.TaskList = Teambox.Models.Base.extend(TaskList);
}());
