(function () {
  var TaskListsForm = { id: 'task_lists_form'
                      , template: Teambox.modules.ViewCompiler('task_lists.form')
                      }
    , TasksHelper = Teambox.helpers.tasks;

  TaskListsForm.events = {
    'click #task_lists_form_cancel': 'toggle'
  };

  TaskListsForm.initialize = function (options) {
    this.parent_view = options.parent_view;
    this.project = options.project;
  };

  /* toggles the new task list form
   *
   * @param {Event} evt
   */
  TaskListsForm.toggle = function (evt) {
    evt.stop();
    this.el.toggle();
  };

  /* updates the element
   *
   * @return self
   */
  TaskListsForm.render = function () {
    this.el.update(this.template({project: this.project}));

    return this;
  };

  // expose
  Teambox.Views.TaskListsForm = Backbone.View.extend(TaskListsForm);

}());
