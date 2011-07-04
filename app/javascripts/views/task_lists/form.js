(function () {
  var TaskListsForm = { id: 'task_lists_form'
                      , template: Teambox.modules.ViewCompiler('task_lists.form')
                      }
    , TasksHelper = Teambox.helpers.tasks;

  TaskListsForm.events = {
    'click #task_lists_form_cancel': 'toggle'
  , 'submit form'                  : 'postTaskList'
  };

  TaskListsForm.initialize = function (options) {
    this.parent_view = options.parent_view;
    this.project = options.project;
  };

  /**
   * Toggles the new task list form
   *
   * @param {Event} evt
   */
  TaskListsForm.toggle = function (evt) {
    evt.stop();
    this.el.toggle();
  };

  /**
   * Syncs the new task_list and triggers `task_list:added`
   *
   * @param {Event} evt
   */
  TaskListsForm.postTaskList = function (evt) {
    if (evt) evt.stop();

    var data = _.deparam(this.el.down('form').serialize(), true);

    (new Teambox.Models.TaskList()).save(data.task_list, {
      success: function (model, response) {
      }
    });
  };

  /**
   * Updates the element
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
