(function () {
  var TaskLists = {};

  TaskLists.parse = function (response) {
    return _.parseFromAPI(response);
  };

  TaskLists.url = function () {
    if (this.get('project_id')) {
      return '/api/1/projects/' + this.get('project_id') + '/task_lists';
    } else {
      return '/api/1/task_lists';
    }
  };

  // exports
  Teambox.Collections.TaskLists = Teambox.Collections.Base.extend(TaskLists);

}());
