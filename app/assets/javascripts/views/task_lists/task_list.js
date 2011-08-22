(function () {
  var TaskList = { className: 'task_list_container'
                  , template: Teambox.modules.ViewCompiler('task_lists.task_list')
                  };

  TaskList.events = {
    'click .task .name': 'showComments'
  , 'click .task_list_rename': 'showRename'
  , 'click .task_list_set_dates': 'showSetDates'
  , 'click a.inline_form_update_cancel': 'hideTaskListForm'
  , 'click a.task_list_resolve': 'resolveTaskList'
  , 'click a.task_list_delete': 'deleteTaskList'
  , 'submit form.task_list_form': 'updateTaskList'
  };

  /**
   * Initializes the view
   *
   * @param {Object} options
   */
  TaskList.initialize = function (options) {
    _.bindAll(this, 'render', 'onDestroy');

    this.project = options.project;
    this.model.bind('change', this.render);
    this.model.bind('destroy', this.onDestroy);
  };

  /**
   * Callback triggered when the task_list is being destroyed
   */
  TaskList.onDestroy = function () {
    jQuery(this.el).remove();

    _.each(this.model.get('tasks'), function (task) {
      task.trigger('destroy');
    });
  };

  /**
   * deleteTaskList
   *
   * @param {Event} evt
   */
  TaskList.deleteTaskList = function (evt) {
    evt.preventDefault();
    if (confirm('Are you sure you want to delete this task list?')) {
      console.log("Commented deleteTaskList when porting to jQuery");
      return;
      var self = this
        , task_list_id = evt.element().ancestors()[3].readAttribute('data-task-list-id')
        , task_list = Teambox.collections.tasks_lists.get(task_list_id);

      task_list.destroy();
    }
  };

  /**
   * resolveTaskList
   *
   * @param {Event} evt
   */
  TaskList.resolveTaskList = function (evt) {
    evt.preventDefault();
    if (confirm('Are you sure you want to resolve and archive this task list?')) {
      console.log("Commented resolveTaskList when porting to jQuery");
      return;
      var self = this
        , task_list_id = evt.element().ancestors()[3].readAttribute('data-task-list-id')
        , task_list = Teambox.collections.tasks_lists.get(task_list_id);

      task_list.archive(function (error, result) {
        if (error) return console.log(error);
        self.el.highlight();
      });
    }
  };

  /**
   * Updates a task list
   *
   * @param {Event} evt
   */
  TaskList.updateTaskList = function (evt) {
    evt.preventDefault();
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
    evt.preventDefault();
    jQuery(evt.currentTarget).parent('.task').find('.thread').toggle();
  };

  /**
   * Toggles the rename form
   *
   * @param {Event} evt
   */
  TaskList.showRename = function (evt) {
    evt.preventDefault();
    var head = jQuery(evt.currentTarget).parent('.head');

    head.find('.actions_menu').hide();
    head.find('span.task_list_name').hide();
    head.find('.task_list_form').show().find('.name.text_field').show();
  };

  /**
   * Toggles the set dates form
   *
   * @param {Event} evt
   */
  TaskList.showSetDates = function (evt) {
    evt.preventDefault();

    var head = jQuery(evt.currentTarget).parent('.head');

    head.find('.actions_menu').hide();
    head.find('.task_list_form').show().find('.date_fields').show();
  };

  /**
   * Hides task_list form
   *
   * @param {Event} evt
   */
  TaskList.hideTaskListForm = function (evt) {
    evt.preventDefault();

    var head = jQuery(evt.currentTarget).parent('.head')
      , task_list_form = head.find('.task_list_form');

    head.find('.actions_menu, span.task_list_name').show();

    task_list_form
      .hide()
      .down('.date_fields, .name.text_field').hide();
  };

  /**
   * Updates the element
   *
   * @return self
   */
  TaskList.render = function () {
    var self = this;

    this.el.id = 'task_list_' + this.model.id;

    jQuery(this.el).html(this.template({task_list: this.model}));
    _.each(this.model.get('tasks'), function (el) {
      self.$('.tasks').prepend(
        (new Teambox.Views.Task({model: el, dragndrop: true})).render().el
      );
    });

    this.$('.date_fields')
      .append(
        (new Teambox.Views.DatePicker({
          model_name: 'task_list'
        , attribute: 'start_on'
        , label: 'Starts on <i>optional</i>'
        , current_date: this.model.get('start_on')
        }).render().el))
      .append(
        (new Teambox.Views.DatePicker({
          model_name: 'task_list'
        , attribute: 'finish_on'
        , label: 'End on <i>optional</i>'
        , current_date: this.model.get('finish_on')
        }).render().el));

    if (!this.model.get('archived')) {
      this.$('.tasks').after((new Teambox.Views.TaskListsTaskForm({
        project: this.project
      , parent_view: this
      , task_list: this.model
      })).render().el);
    } else {
      this.el.addClass('archived');
    }

    return this;
  };

  // expose
  Teambox.Views.TaskList = Backbone.View.extend(TaskList);

}());
