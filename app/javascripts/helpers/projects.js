/*globals Templates*/
(function () {
  var ProjectsHelper = {};

  /* select tasks matching assigned/due_date
   *
   * @param {String} name
   * @param {String} klass
   * @return {Array} tasks matched
   */
    ProjectsHelper.filterActivitiesByProject = function (id, collection) {
      return new Teambox.Collections.Threads(collection.select(function (a) {
        return a.get('project_id') === id;
      }));
    };

    ProjectsHelper.getPeople = function(project_id) {
      var project = Teambox.collections.projects.get(project_id);
      return project.get('people').models;
    };

    ProjectsHelper.getUsers = function(project_id) {
      return _.map(ProjectsHelper.getPeople(project_id), function(person) { return person.get('user');});
    };



  // expose
  Teambox.helpers.projects = ProjectsHelper;

}());
