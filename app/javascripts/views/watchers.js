(function () {

  var Watchers = { className: 'add_watchers_box'
                 , template: Handlebars.compile(Templates.partials.add_watchers)
                 };

  Watchers.events = {
    'click .watcher a': 'addWatcher'
  };

  Watchers.initialize = function (options) {
    _.bindAll(this, "render");

    this.project = Teambox.collections.projects.get(this.model.get('project_id'));
  };

  // Draw the Add Watchers box and populate it with watchers
  Watchers.render = function () {
    var users = _.map(this.project.get('people').models, function (person) {
          return person.get('user');
        });

    this.el.update(this.template({users: users})).hide();

    return this;
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
