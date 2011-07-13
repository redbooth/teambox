(function () {
  var TaskLists = { model: Teambox.Models.TaskList};

  TaskLists.parse = function (response) {
    return _.parseFromAPI(response);
  };

  /**
   * Get the API url
   *
   * @return {String}
   */
  TaskLists.url = function () {
    var base_url = '/api/1';

    if (this.options.project_id) {
      base_url += '/projects/' + this.options.project_id;
    }

    return base_url + '/task_lists.json';
  };

  /**
   * Sets the tasks as attributes on each task_list
   *
   * @param {Array} tasks
   * @return self
   */
  TaskLists.setTasks = function (tasks) {
    var ids = {};

    this.models.each(function (task_list) {
      ids[task_list.id] = task_list; // cache reference
      task_list.set({tasks: []}, {silent: true});
    });

    tasks.each(function (task) {
      ids[task.get('task_list_id')].attributes.tasks.push(task);
    });

    return this;
  };

  /**
   * Comparator function
   *
   * @param {Object} task_list
   * @return {Integer}
   */
  TaskLists.comparator = function (task_list) {
    return task_list.get('position');
  };

  // exports
  Teambox.Collections.TaskLists = Teambox.Collections.Base.extend(TaskLists);

}());
