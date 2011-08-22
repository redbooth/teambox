(function () {
  var TaskLists = { title: 'Tasks'
                  , template: Teambox.modules.ViewCompiler('task_lists.index')
                  , primer_template: Teambox.modules.ViewCompiler('primers.my_tasks')
                  }
    , TasksHelper = Teambox.helpers.tasks;

  TaskLists.events = {
    'click #toggle_new_task_list': 'toggleNewTaskListForm'
  , 'click #reorder_task_lists': 'toggleReorder'
  , 'click #done_reordering_task_lists': 'toggleReorder'
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
   * Insert the comments below the task clicked
   *
   * @param {Event} evt
   */
  TaskLists.toggleReorder = function (evt) {
    evt && evt.preventDefault();

    var holder = this.$('#task_lists')
      , container = this.$('.task_list_container');

    if (holder.hasClass('reordering')) {
      container.removeClass('reordering');
      holder.removeClass('reordering');
      this.$('#done_reordering_task_lists').swapVisibility('reorder_task_lists');
      this.$('.filters').show();
      this.destroySortable();
    } else {
      container.addClass('reordering');
      holder.addClass('reordering');
      this.$('#reorder_task_lists').swapVisibility('done_reordering_task_lists');
      this.$('.filters').hide();
      this.makeTaskListSortable();
    }
  };

  /**
   * inserts a task list
   *
   * @param {Object} model
   */
  TaskLists.insertTaskList = function (model) {
    var el = (new Teambox.Views.TaskList({model: model, project: this.project})).render().el;

    if (model.get('archived')) {
      this.$('#task_lists').append(el);
    } else {
      this.$('#task_lists').prepend(el);
    }

    //new Effect.Highlight(el, {duration:3});
  };

  /**
   * Toggles the new task list form
   *
   * @param {Event} evt
   */
  TaskLists.toggleNewTaskListForm = function (evt) {
    evt && evt.preventDefault();
    this.new_task_list_form_view.toggle(evt);
  };

  /**
   * Makes the task lists sortable
   */
  TaskLists.makeTaskListSortable = function () {
    var self = this;

    function onChange(draggable) {
      self.current_draggable = draggable;
    }

    function onUpdate() {
      var task_list_ids = _(self.current_draggable.parent().find('div.task_list')).map(
        function (task_list) { return task_list.attr('data-task-list-id'); });

      new Ajax.Request(self.collection.url() + '/reorder', {
        method: 'put'
      , parameters: {task_list_ids: task_list_ids.join(',')}
      });
    }

    Sortable.create('task_lists', {
      constraint: 'vertical'
    , handle: 'task_drag'
    , tag: 'div'
    , only: 'task_list_container'
    , onChange: onChange
    , onUpdate: _.debounce(onUpdate, 1000) // take your time dude
    });
  };

  /**
   * Destroy task lists sortable
   */
  TaskLists.destroySortable = function () {
    Sortable.destroy('task_lists');
  };

  /**
   * Make a task sortable
   *
   * @param {Integer} sortable_id
   * @param {Array} all_sortable_ids
   */
  TaskLists.makeTaskSortable = function (sortable_id, all_sortable_ids) {
    var self = this;

    function onChange(draggable) {
      self.current_draggable = draggable;
    }

    function onUpdate() {
      var task_id = self.current_draggable.attr('data-task-id')
        , task_list = self.current_draggable.parent('.task_list')
        , task_list_id = task_list.attr('data-task-list-id')
        , task_ids = _(task_list.find('.tasks .task')).chain()
            .collect(function (task) {
              return task.attr('data-task-id');
            }).join(',').value();

      new Ajax.Request('/api/1/projects/' + self.project.id + '/tasks/' + task_id + '/reorder', {
        method: 'put',
        parameters: {task_list_id: task_list_id, task_ids: task_ids}
      });
    }

    Sortable.create(sortable_id, {
      constraint: 'vertical'
    , containment: all_sortable_ids
    , handle: 'task_drag'
    , dropOnEmpty: true
    , tag: 'div'
    , onChange: onChange
    , onUpdate: _.debounce(onUpdate, 1000) // take your time dude
    });
  };

  /**
   * Make all tasks sortable
   */
  TaskLists.makeAllTasksSortable = function () {
    var self = this
      , sortable_ids = _(jQuery('.tasks.open')).map(function (tasks_div) {
          return tasks_div.identify();
        });

    sortable_ids.each(function (sortable_id) {
      self.makeTaskSortable(sortable_id, sortable_ids);
    });
  };

  /**
   * Updates the element
   *
   * @return self
   */
  TaskLists.render = function () {
    var self = this;

    if (this.collection.length) {
      jQuery(this.el).html(this.template({project: this.project}));
      this.collection.each(function (el) {
        self.$('#task_lists')
          .append((new Teambox.Views.TaskList({model: el, project: self.project})).render().el);
      });
    } else {
      jQuery(this.el).html(this.primer_template());
    }

    // insert new task lists form hidden and filters
    this.$('#task_lists')
      .before( this.new_task_list_form_view.render().el.hide() )
      .before( this.filters_view.render().el );

    return this;
  };

  // expose
  Teambox.Views.TaskLists = Backbone.View.extend(TaskLists);

}());
