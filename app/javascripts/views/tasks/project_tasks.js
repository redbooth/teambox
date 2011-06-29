(function () {
  var ProjectTasks = { title: 'Tasks'
                     , template: Teambox.modules.ViewCompiler('tasks.index')
                     , primer_template: Teambox.modules.ViewCompiler('primers.my_tasks')
                     }
    , TasksHelper = Teambox.helpers.tasks;

  ProjectTasks.makeSortable = function (task_id, all_task_ids) {
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

  ProjectTasks.makeAllSortable = function () {
    var task_div_ids = this.el.select('.tasks.open').map(function (task_div) {
          return task_div.identify();
        });

    task_div_ids.each(function (task_div_id) {
      ProjectTasks.makeSortable(task_div_id, task_div_ids);
    });
  };

  ProjectTasks.initialize = function (options) {
    _.bindAll(this, 'render');

    this.project = options.project;

    ['change', 'add', 'remove'].each(function (event) {
      this.collection.unbind(event);
      this.collection.bind(event, this.render);
    }.bind(this));
  };

  /* updates the element
   *
   * @return self
   */
  ProjectTasks.render = function () {
    TasksHelper.render.call(this, { tasks: this.collection.models
                                  , title: this.title
                                  , template: this.template
                                  , dragndrop: true
                                  , primer_template: this.primer_template });

    TasksHelper.group({ tasks: this.el.select('.task')
                      , where: this.el.down('.tasks')
                      , by: 'task_list' });

    this.makeAllSortable();

    return this;
  };

  // expose
  Teambox.Views.ProjectTasks = Backbone.View.extend(ProjectTasks);

}());
