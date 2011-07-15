(function () {

  var Watchers = { className: 'add_watchers_box'
                 , template: Teambox.modules.ViewCompiler('partials.add_watchers')
                 };

  Watchers.events = {
    'click .watcher a': 'addWatcher'
  };

  Watchers.initialize = function (options) {
    _.bindAll(this, "render", "update");

    var project_id = this.model.get('project_id');
    if (project_id) {
      this.setProject(project_id);
    }
  };

  /* Draw the Add Watchers box and populate it with watchers
   *
   * @return self
   */
  Watchers.setProject = function (project_id) {
    this.project = Teambox.collections.projects.get(project_id);
  };

  /* Draw the Add Watchers box and populate it with watchers
   *
   * @return self
   */
  Watchers.render = function () {
    this.update();
    this.el.hide();
    return this;
  };

  /* Rerender watchers list
   *
   * @param {Event} evt
   * @return false
   */
  Watchers.update = function (project_id) {
    if (project_id) {
      this.setProject(project_id);
    }

    if (this.project) {
      var users = _.map(this.project.get('people').models, function (person) {
            return person.get('user');
          });
      this.el.update(this.template({users: users}));
    }
  };

  /* Add @username to the textarea when clicking on a user
   *
   * @param {Event} evt
   * @return false
   */
  Watchers.addWatcher = function (evt) {
    evt.stop();

    var el = evt.element()
      , textarea = el.up("form").down("textarea")
      , login = el.readAttribute('data-login');

    if (textarea.value.length > 0 && textarea.value[textarea.value.length - 1] !== ' ') {
      textarea.value += " ";
    }

    textarea.value += '@' + login + ' ';

    return false;
  }

  // exports
  Teambox.Views.Watchers = Backbone.View.extend(Watchers);
}());
