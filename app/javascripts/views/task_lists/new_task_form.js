(function () {
  var TaskListsTaskForm = { className: 'new_task_form'
                          , template: Teambox.modules.ViewCompiler('task_lists.new_task_form')
                          }
    , TasksHelper = Teambox.helpers.tasks;

  TaskListsTaskForm.events = {
    'click a.cancel': 'toggle'
  //, 'submit form'                  : 'postTask'
  };

  /**
   * Constructor
   *
   * @param {Object} options
   */
  TaskListsTaskForm.initialize = function (options) {
    this.task_list = options.task_list;
  };

  /**
   * Toggles the new task form
   *
   * @param {Event} evt
   */
  TaskListsTaskForm.toggle = function (evt) {
    evt.stop();
    this.el.toggle();
  };

  /**
   * Syncs the new task and triggers `task:added`
   *
   * @param {Event} evt
   */
  TaskListsTaskForm.postTaskList = function (evt) {
    if (evt) evt.stop();

    var data = _.deparam(this.el.down('form').serialize(), true);

    (new Teambox.Models.Task()).save(data.task, {
      success: function (model, response) {
      }
    });
  };

  /**
   * Updates the element
   *
   * @return self
   */
  TaskListsTaskForm.render = function () {
    this.el.update(this.template({task_list: this.task_list}));

    return this;
  };

  // expose
  Teambox.Views.TaskListsTaskForm = Backbone.View.extend(TaskListsTaskForm);

}());
