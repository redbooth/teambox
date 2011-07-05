(function () {
  var TaskListsForm = { id: 'task_lists_form'
                      , template: Teambox.modules.ViewCompiler('task_lists.form')
                      }
    , TasksHelper = Teambox.helpers.tasks;

  TaskListsForm.events = {
    'click #task_lists_form_cancel': 'toggle'
  , 'submit form'                  : 'postTaskList'
  , 'click .date_picker'           : 'showCalendar'
  };

  /**
   * Constructor
   *
   * @param {Object} options
   */
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
    if (evt) evt.stop();
    this.el.toggle();
  };

  /**
   * Displays the calendar
   *
   * @param {Event} evt
   * @param {DOM} element
   */
  TaskListsForm.showCalendar = function (evt, element) {
    evt.stop();

    new Teambox.modules.CalendarDateSelect(element.down('input'), element.down('span'), {
      buttons: true
    , popup: 'force'
    , time: false
    , year_range: [2008, 2020]
    });
  };

  /**
   * Syncs the new task_list
   *
   * @param {Event} evt
   */
  TaskListsForm.postTaskList = function (evt) {
    if (evt) evt.stop();

    var data = _.deparam(this.el.down('form').serialize(), true)
      , self = this;

    (new Teambox.Models.TaskList()).save(data.task_list, {
      success: function (model, response) {

        Teambox.collections.tasks_lists.add(model, {at: 0});
        self.project.get('task_lists').add(model, {at: 0});

        self.toggle();
        self.render();
        self.parent_view.insertTaskList(model);
      }
    });
  };

  /**
   * Updates the DOM element
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
