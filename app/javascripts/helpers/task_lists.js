/*globals Templates*/
(function () {
  var TaskListsHelper = {};

  /**
   * Return a collection of task lists suitable for DropDowns
   *
   * @param {String} name
   * @return {Array} tasks matched
   */
  TaskListsHelper.taskListsCollection = function(project_id) {
    var project = Teambox.collections.projects.get(project_id)
    , task_lists = project.get('task_lists').models
    , collection =  _.map(task_lists, function (task_list) {
      return {value: task_list.id, label: task_list.get('name')};
    });

    if (!_.any(collection, function(e) {return e.label === 'Inbox';})) {
      collection.unshift({value: '', label: 'Inbox'});
    }

    return collection;
  }

  // expose
  Teambox.helpers.task_lists = TaskListsHelper;

}());
