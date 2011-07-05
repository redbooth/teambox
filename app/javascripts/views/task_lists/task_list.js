(function () {
  var TaskList = { className: 'task_list'
                  , template: Teambox.modules.ViewCompiler('task_lists.task_list')
                  };

  TaskList.events = {
    'click .task .name': 'showComments'
  , 'click .new_task a.toggle': 'toggleNewTask'
  };

  /**
   * Initializes the view
   *
   * @param {Object} options
   */
  TaskList.initialize = function (options) {
    _.bindAll(this, 'render');
  };

  /**
   * Insert the comments below the task clicked
   *
   * @param {Event} evt
   */
  TaskList.showComments = function (evt) {
    evt.stop();
    evt.element().up('.task').down('.thread').toggle();
  };

  /**
   * Toggles the new task form
   *
   * @param {Event} evt
   */
  TaskList.toggleNewTask = function (evt) {
    var element = evt.element();

    evt.stop();
    element.next().toggle(evt);
  };

  /**
   * Updates the element
   *
   * @return self
   */
  TaskList.render = function () {
    this.el.update(this.template({task_list: this.model}));
    return this;
  };

  // expose
  Teambox.Views.TaskList = Backbone.View.extend(TaskList);

}());
