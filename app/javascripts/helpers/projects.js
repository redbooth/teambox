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

   /* Returns array of Person models belonging to project
    * with the supplied project_id.
    *
    * @param {Integer} project_id
    * @return {Array} people matched
    */
    ProjectsHelper.getPeople = function(project_id) {
      var project = Teambox.collections.projects.get(project_id);
      return project.get('people').models;
    };

   /* Returns array of User models belonging to project
    * with the supplied project_id.
    *
    * @param {Integer} project_id
    * @return {Array} users matched
    */
    ProjectsHelper.getUsers = function(project_id) {
      return _.map(ProjectsHelper.getPeople(project_id), function(person) { return person.get('user');});
    };

   /* Returns array of Person models belonging to user
    * with the supplied user_id.
    *
    * @param {Integer} user_id
    * @return {Array} people matched
    */
    ProjectsHelper.getMyRoles = function(user_id) {
      var projects = Teambox.collections.projects.models;
      return _.flatten(projects.collect(function(p) { return p.get('people').models;})).select(function(p) {
        return p.get('user_id') === user_id;
      });
    };

   /* Returns array of Project ids in which the user
    * with the supplied user_id is an admin.
    *
    * @param {Integer} user_id
    * @return {Array} project ids matched
    */
    ProjectsHelper.getMyAdminProjects = function(user_id) {
      return ProjectsHelper.getMyRoles(user_id)
      .select(function(p) { return (p.get('role') === 3);})
      .collect(function(p) { return p.get('project_id');});
    };

  // expose
  Teambox.helpers.projects = ProjectsHelper;

}());
