(function () {
  var TaskListsTaskForm = { className: 'new_task'
                          , template: Teambox.modules.ViewCompiler('task_lists.new_task_form')
                          }
    , TasksHelper = Teambox.helpers.tasks;

  TaskListsTaskForm.events = {
    'click .date_picker'       : 'showCalendar'
  , 'click a.cancel'           : 'toggleNewTask'
  , 'click .new_task a.toggle' : 'toggleNewTask'
  , 'submit form'              : 'postTask'
  };

  /**
   * Constructor
   *
   * @param {Object} options
   */
  TaskListsTaskForm.initialize = function (options) {
    this.parent_view = options.parent_view;
    this.task_list = options.task_list;
    this.project = options.project;
  };

  /**
   * Toggles the new task form
   *
   * @param {Event} evt
   */
  TaskListsTaskForm.toggleNewTask = function (evt) {
    evt.stop();
    this.el.down('form').toggle();
  };

  /**
   * Displays the calendar
   *
   * @param {Event} evt
   * @param {DOM} element
   */
  TaskListsTaskForm.showCalendar = function (evt, element) {
    evt.stop();

    new Teambox.modules.CalendarDateSelect(element.down('input'), element.down('span'), {
      buttons: true
    , popup: 'force'
    , time: false
    , year_range: [2008, 2020]
    });
  };

  /**
   * Syncs the new task and triggers `task:added`
   *
   * @param {Event} evt
   */
  TaskListsTaskForm.postTask = function (evt) {
    if (evt) evt.stop();

    var self = this
      , data = _.deparam(this.el.down('form').serialize(), true);

    (new Teambox.Models.Task()).save(data.task, {
      success: function (model, response) {
        self.parent_view.el.down('.tasks').insert({top: (new Teambox.Views.Task({model: model})).render().el});
        Teambox.collections.tasks.add(model, {at: 0});
        Teambox.collections.threads.add((new Teambox.Models.Thread(response)), {at: 0});
        self.task_list.get('tasks').push(model);
        self.el.toggle();
      }
    });
  };

  /**
   * Updates the element
   *
   * @return self
   */
  TaskListsTaskForm.render = function () {
    this.el.update(this.template({task_list: this.task_list, project: this.project}));

    // select assigned
    (new Teambox.Views.SelectAssigned({
      el: this.el.down('#task_assigned_id')
    , selected: null
    , project: this.project
    })).render();

    return this;
  };

  // expose
  Teambox.Views.TaskListsTaskForm = Backbone.View.extend(TaskListsTaskForm);

}());
