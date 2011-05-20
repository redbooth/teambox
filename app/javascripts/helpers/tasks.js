/*globals Templates*/
(function () {
  var TasksHelper = {};

  TasksHelper.render = function (options) {
    $('view_title').update(options.title);
    if (options.tasks.length > 0) {
      $('content').update(options.template());
      options.tasks.each(function (task) {
        var view = new Teambox.Views.Task({ model: task });
        //TODO: render tasks on a document fragment and insert it only once to avoid reflow
        $$('.task_list .tasks')[0].insert({ bottom: view.render().el });
      });
    } else {
      $('content').update(options.primer_template());
    }
  };

  /* shows all task_list containers
   * @return self
   */
  TasksHelper.showAllTaskLists = function () {
    $$(".task_list_container").invoke('show');
    return TasksHelper;
  };

  /* changes visibility of all tasks
   * @param {Boolean} show
   * @return self
   */
  TasksHelper.displayAllTasks = function (show) {
    var verb = show ? 'show' : 'hide';
    $$(".tasks div.task").invoke(verb);
    $$(".tasks.closed div.task").invoke(verb);
    return TasksHelper;
  };

  /* Hides task lists if they don't have any visible tasks
   * @retun self
   */
  TasksHelper.foldEmptyTaskLists = function () {
    $$("div.task_list").each(function (e) {
      var container = e.up('.task_list_container'), visible_tasks;

      if (!container) {
        return;
      }

      if (container.hasClassName('archived')) {
        container.hide();
        return;
      }

      visible_tasks = e.select(".task").reject(function (e) {
        return e.getStyle("display") === "none";
      });

      if (visible_tasks.length === 0) {
        container.hide();
      }
    });

    return TasksHelper;
  };

  /* select tasks matching a name
   *
   * @param {String} name
   * @return {Array} tasks matched
   */
  TasksHelper.selectName = function (tasks, name) {
    name = name.toLowerCase();
    return tasks.select(function (t) {
      return t.down('a.name').innerHTML.toLowerCase().match(name);
    });
  };

  /* select tasks matching assigned/due_date
   *
   * @param {String} name
   * @param {String} klass
   * @return {Array} tasks matched
   */
  _.each(['Assigned', 'DueDate', 'Status'], function (filter) {
    TasksHelper['select' + filter] = function (tasks, klass) {
      return tasks.select(function (t) {
        return t.hasClassName(klass);
      });
    };
  });

  // expose
  Teambox.helpers.tasks = TasksHelper;

}());
