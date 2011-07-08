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
    if (evt) evt.stop();

    var holder = this.el.down('#task_lists')
      , container = this.el.select('.task_list_container');

    if (holder.hasClassName('reordering')) {
      container.invoke('removeClassName', 'reordering');
      holder.removeClassName('reordering');
      this.el.down('#done_reordering_task_lists').swapVisibility('reorder_task_lists');
      this.el.select('.filters').invoke('show');
      this.destroySortable();
    } else {
      container.invoke('addClassName', 'reordering');
      holder.addClassName('reordering');
      this.el.down('#reorder_task_lists').swapVisibility('done_reordering_task_lists');
      this.el.select('.filters').invoke('hide');
      this.makeSortable();
    }
  };

  /**
   * inserts a task list
   *
   * @param {Object} model
   */
  TaskLists.insertTaskList = function (model) {
    var el = (new Teambox.Views.TaskList({model: model, project: this.project})).render().el;

    this.el
      .down('#task_lists')
      .insert(model.get('archived') ? {bottom: el}
                                    : {top: el});

    new Effect.Highlight(el, {duration:3});
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

  /**
   * Makes the task lists sortable
   */
  TaskLists.makeSortable = function () {
    var self = this;

    function onChange(draggable) {
      self.current_draggable = draggable;
    }

    function onUpdate() {
      var task_list_ids = self.current_draggable.up().select('div.task_list').map(function (task_list) {
            return task_list.readAttribute('data-task-list-id');
          });

      new Ajax.Request('/api/1/projects/' + self.project.id + '/task_lists/reorder', {
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
    , onUpdate: _.throttle(onUpdate, 1000) // take your time dude
    });
  };

  /**
   * Destroy task lists sortable
   */
  TaskLists.destroySortable = function () {
    Sortable.destroy('task_lists');
  };

  /**
   * Updates the element
   *
   * @return self
   */
  TaskLists.render = function () {
    var self = this;

    if (this.collection.length > 0) {
      this.el.update(this.template({project: this.project}));
      this.collection.each(function (el) {
        self.el.down('#task_lists')
          .insert({bottom: (new Teambox.Views.TaskList({model: el, project: self.project})).render().el});
      });
    } else {
      this.el.update(this.primer_template());
    }

    // insert new task lists form hidden
    this.el.down('#task_lists').insert({
      before: this.new_task_list_form_view.render().el.hide()
    });

    // filters
    this.el.down('#task_lists').insert({
      before: this.filters_view.render().el
    });

    return this;
  };

  // expose
  Teambox.Views.TaskLists = Backbone.View.extend(TaskLists);

}());
