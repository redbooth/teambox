(function () {

  var TaskList = {};

  /* Get the public url
   *
   * @return {String}
   */
  TaskList.publicUrl = function () {
    return '/projects/' + this.get('project_id') + '/task_lists/' + this.id;
  };


  // exports
  Teambox.Models.TaskList = Teambox.Models.Base.extend(TaskList);
}());
