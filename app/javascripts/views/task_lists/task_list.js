(function () {
  var TaskList = { className: 'task_list_container'
                  , template: Teambox.modules.ViewCompiler('task_lists.task_list')
                  };

  TaskList.events = {
    'click .task .name': 'showComments'
  , 'click .task_list_rename': 'showRename'
  , 'click .task_list_set_dates': 'showSetDates'
  , 'click a.inline_form_update_cancel': 'hideTaskListForm'
  , 'submit form.task_list_form': 'updateTaskList'
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
   * Updates a task list
   *
   * @param {Event} evt
   */
  TaskList.updateTaskList = function (evt) {
    evt.stop();
    var data = _.deparam(evt.element().serialize(), true)
      , self = this
      , task_list = Teambox.collections.tasks_lists.get(data.task_list.id)
      , attr;

    delete data.task_list.id;

    task_list.save(data.task_list, {success: self.render});
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
   * Toggles the rename form
   *
   * @param {Event} evt
   */
  TaskList.showRename = function (evt) {
    evt.stop();
    var head = evt.element().up('.head');

    head.down('.actions_menu').hide();
    head.down('span.task_list_name').hide();
    head.down('.task_list_form').show().down('.name.text_field').show();
  };

  /**
   * Toggles the set dates form
   *
   * @param {Event} evt
   */
  TaskList.showSetDates = function (evt) {
    evt.stop();

    var head = evt.element().up('.head');

    head.down('.actions_menu').hide();
    head.down('.task_list_form').show().down('.date_fields').show();
  };

  /**
   * Hides task_list form
   *
   * @param {Event} evt
   */
  TaskList.hideTaskListForm = function (evt) {
    evt.stop();

    var head = evt.element().up('.head')
      , task_list_form = head.down('.task_list_form');

    head.down('.actions_menu').show();
    head.down('span.task_list_name').show();

    task_list_form.hide();
    task_list_form.down('.date_fields').hide();
    task_list_form.down('.name.text_field').hide();
  };

  /**
   * Updates the element
   *
   * @return self
   */
  TaskList.render = function () {
    var self = this;

    this.el.id = 'task_list_' + this.model.id;

    this.el.update(this.template({task_list: this.model}));
    _.each(this.model.get('tasks'), function (el) {
      self.el.down('.tasks').insert({top: (new Teambox.Views.Task({model: el, dragndrop: true})).render().el});
    });

    this.el.down('.date_fields')
      .insert({
        bottom: (new Teambox.Views.DatePicker({
          model_name: 'task_list'
        , attribute: 'start_on'
        , label: 'Starts on <i>optional</i>'
        , current_date: this.model.get('start_on')
        }).render().el)
      })
      .insert({
        bottom: (new Teambox.Views.DatePicker({
          model_name: 'task_list'
        , attribute: 'finish_on'
        , label: 'End on <i>optional</i>'
        , current_date: this.model.get('finish_on')
        }).render().el)
      });

    this.el.down('.tasks').insert({after: (new Teambox.Views.TaskListsTaskForm({
      project: this.project
    , parent_view: this
    , task_list: this.model
    })).render().el});

    return this;
  };

  // expose
  Teambox.Views.TaskList = Backbone.View.extend(TaskList);

}());
