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
      return new Teambox.Collections.Projects(collection.select(function (a) {
        return a.get('project_id') === id;
      }));
    };

  // expose
  Teambox.helpers.projects = ProjectsHelper;

}());
