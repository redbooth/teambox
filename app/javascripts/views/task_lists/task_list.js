(function () {
  var TaskList = { className: 'task_list'
                  , template: Teambox.modules.ViewCompiler('task_lists.task_list')
                  };

  TaskList.events = {
    'click .task .name': 'showComments'
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
   * Updates the element
   *
   * @return self
   */
  TaskList.render = function () {
    var self = this;

    this.el.update(this.template({task_list: this.model}));
    _.each(this.model.get('tasks'), function (el) {
      self.el.down('.tasks').insert({top: (new Teambox.Views.Task({model: el, dragndrop: true})).render().el});
    });

    this.el.down('.tasks').insert({bottom: (new Teambox.Views.TaskListsTaskForm({
      project: this.project
    , parent_view: this
    , task_list: this.model
    })).render().el});

    return this;
  };

  // expose
  Teambox.Views.TaskList = Backbone.View.extend(TaskList);

}());
