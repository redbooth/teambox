(function () {
  var TaskCollection = {model: Teambox.Models.Task};

  /* Fetch references from the API response
   *
   * @param {Object} response
   * @return {Object} parsed response
   */
  TaskCollection.parse = function (response) {
    return _.parseFromAPI(response);
  };

  /* Url to fetch and save tasks
   *
   * @return {String} url
   */
  TaskCollection.url = function () {
    return '/api/1/tasks';
  };

  /* Active tasks assigned to me
   *
   * @return {Array} filtered models
   */
  TaskCollection.mine = function () {
    return this.filter(function (t) {
      var assigned = t.get('assigned');
      return assigned && (assigned.user.id === my_user.id);
    });
  };

  /* Active tasks assigned to me that are due today or late
   *
   * @return {Array} filtered models
   */
  TaskCollection.today = function () {
    return this.mine().filter(function (t) {
      var today = new Date()
        , tomorrow = today.setDate(today.getDate() + 1)
        , due = t.get('due_on');

      return due && new Date(due) < tomorrow;
    });
  };

  /* Active tasks assigned to me that are late
   *
   * @return {Array} filtered models
   */
  TaskCollection.late = function () {
    return this.mine().filter(function (t) {
      var today = new Date()
        , due = t.get('due_on');

      return due && new Date(due) < today;
    });
  };

  /* Tasks belonging to a project
   *
   * @param {String} project_permalink
   * @return {Array} filtered models
   */
  TaskCollection.filteredByProject = function (project) {
    return this.filter(function (el) {
      return el.get('project').permalink === project;
    });
  };

  // exports
  Teambox.Collections.Tasks = Teambox.Collections.Base.extend(TaskCollection);
}());
