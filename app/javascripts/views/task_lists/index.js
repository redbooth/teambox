(function () {
  var TaskLists = { title: 'Tasks'
                  , id: 'task_lists'
                  , template: Teambox.modules.ViewCompiler('task_lists.index')
                  , primer_template: Teambox.modules.ViewCompiler('primers.my_tasks')
                  }
    , TasksHelper = Teambox.helpers.tasks;

  TaskLists.events = {
    'click .task .name': 'showComments'
  , 'click #toggle_new_task_list': 'toggleNewTaskListForm'
  , 'click #reorder_task_lists': 'toggleReorder'
  , 'click #done_reordering_task_lists': 'toggleReorder'
  , 'click .date_picker' : 'showCalendar'
  };

  /**
   * Initializes the view
   *
   * @param {Object} options
   */
  TaskLists.initialize = function (options) {
    _.bindAll(this, 'render', 'toggleReorder');

    this.project = options.project;
    this.new_task_list_form_view = new Teambox.Views.TaskListsForm({parent_view: this, project: options.project});
    this.filters_view = new Teambox.Views.Filters({ task_list: this
                                                  , filters: { name: null
                                                             , assigned: null
                                                             , due_date: null
                                                             , status: null }});
  };

  /**
   * Displays the calendar
   *
   * @param {Event} evt
   */
  TaskLists.showCalendar = function (evt, element) {
    evt.stop();

    new Teambox.modules.CalendarDateSelect(element.down('input'), element.down('span'), {
      buttons: true
    , popup: 'force'
    , time: false
    , year_range: [2008, 2020]
    });
  };

  /**
   * Insert the comments below the task clicked
   *
   * @param {Event} evt
   */
  TaskLists.toggleReorder = function (evt) {
    if (evt) evt.stop();

    var container = this.el.down('.task_list_container');

    if (container.hasClassName('reordering')) {
      container.removeClassName('reordering');
      this.el.down('#done_reordering_task_lists').swapVisibility('reorder_task_lists');
      // Filter.updateFilters();
      this.el.select('.filters').invoke('show');
      TaskLists.destroySortable();
    } else {
      container.addClassName('reordering');
      this.el.down('#reorder_task_lists').swapVisibility('done_reordering_task_lists');
      // Filter.showAllTaskLists();
      this.el.select('.filters').invoke('hide');
      TaskLists.makeSortable();
    }
  };

  /**
   * Insert the comments below the task clicked
   *
   * @param {Event} evt
   */
  TaskLists.showComments = function (evt) {
    evt.stop();
    evt.element().up('.task').down('.thread').toggle();
  };

  /**
   * Toggles the new task list form
   *
   * @param {Event} evt
   */
  TaskLists.toggleNewTaskListForm = function (evt) {
    evt.stop();
    this.new_task_list_form_view.toggle(evt);
  };

  TaskLists.makeSortable = function (task_id, all_task_ids) {
    var self = this;

    Sortable.create(task_id, {
      constraint: 'vertical'
    , containment: all_task_ids
    , handle: 'task_drag'
    , dropOnEmpty: true
    , tag: 'div'
    , onChange: function (draggable) {
        self.current_draggable = draggable;
      }
    , onUpdate: _.debounce(function () {
        var taskId = self.current_draggable.readAttribute('data-task-id')
          , taskList = self.current_draggable.up('.task_list')
          , taskListId = taskList.readAttribute('data-task-list-id')
          , taskIds = taskList.select('.tasks .task').collect(function (task) {
              return task.readAttribute('data-task-id');
            }).join(',');

        new Ajax.Request('/projects/' + self.project + '/tasks/' + taskId + '/reorder', {
          method: 'put'
        , parameters: {task_list_id: taskListId, task_ids: taskIds}
        });
      }, 100)
    });
  };

  /**
   * Destroy all sortable
   */
  TaskLists.destroySortable = function () {
    Sortable.destroy('task_lists');
  };

  /**
   * Make all task lists sortable
   */
  TaskLists.makeAllSortable = function () {
    var task_div_ids = this.el.select('.tasks.open').map(function (task_div) {
          return task_div.identify();
        });

    task_div_ids.each(function (task_div_id) {
      TaskLists.makeSortable(task_div_id, task_div_ids);
    });
  };

  /**
   * Updates the element
   *
   * @return self
   */
  TaskLists.render = function () {
    var tasks = this.collection.sortBy(function (el) {
          return el.get('task_list_id');
        });

    if (tasks.length > 0) {
      this.el.update(this.template({tasks: tasks, project: this.project}));
    } else {
      this.el.update(this.primer_template());
    }

    // insert new task lists form hidden
    this.el.down('.task_list_container').insert({
      before: this.new_task_list_form_view.render().el.hide()
    });

    this.el.insert({top: this.filters_view.render().el});

    return this;
  };

  // expose
  Teambox.Views.TaskLists = Backbone.View.extend(TaskLists);

}());
