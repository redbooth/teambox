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

    this.project = options.project;
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
    var self = this;

    this.el.update(this.template({task_list: this.model}));
    _.each(this.model.get('tasks'), function (el) {
      self.el.down('.tasks').insert({top: (new Teambox.Views.Task({model: el})).render().el});
    });

    // select assigned
    (new Teambox.Views.SelectAssigned({
      el: this.el.down('#task_assigned_id')
    , selected: null
    , project: this.project
    })).render();

    return this;
  };

  // expose
  Teambox.Views.TaskList = Backbone.View.extend(TaskList);

}());
