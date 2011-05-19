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

  /* shows all tasks
   * @return self
   */
  TasksHelper.showAllTasks = function () {
    $$(".tasks div.task").invoke('show');
    $$(".tasks.closed div.task").invoke('show');
    return TasksHelper;
  };

  /* hides all tasks
   * @return self
   */
  TasksHelper.hideAllTasks = function () {
    $$(".tasks div.task").invoke('hide');
    $$(".tasks.closed div.task").invoke('hide');
    return TasksHelper;
  };

  /* gets all the tasks according a filter
   *
   * @param {String} assigned
   * @param {String} due_date
   *
   * @return {Array} filtered tasks
   */
  TasksHelper.filterTasks = function (assigned, due_date) {
    return $$(".tasks div." + assigned).select(function (e) {
      return (due_date === null || e.hasClassName(due_date));
    });
  };

  /* shows all the tasks according a filter
   *
   * @param {String} assigned
   * @param {String} due_date
   *
   * @return self
   */
  TasksHelper.showTasks = function (assigned, due_date) {
    TasksHelper.hideAllTasks().filterTasks(assigned, due_date).invoke('show');
  };

  /* hides all the tasks according a filter
   *
   * @param {String} assigned
   * @param {String} due_date
   *
   * @return self
   */
  TasksHelper.hideTasks = function (assigned, due_date) {
    TasksHelper.showAllTasks().filterTasks(assigned, due_date).invoke('hide');
  };

  /* counts all the tasks according a filter
   *
   * @param {String} assigned
   * @param {String} due_date
   *
   * @return {Integer} number of matching tasks
   */
  TasksHelper.countTasks = function (assigned, due_date) {
    return TasksHelper.filterTasks(assigned, due_date).length;
  };

  /* Hides task lists if they don't have any visible tasks
   * @param {String} assigned
   * @param {String} due_date
   *
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

  /* shows or hides tasks matching a name
   *
   * @param {String} name
   * @param {Boolean} show
   * @retun self
   */
  TasksHelper.displayByName = function (name, show) {
    name = name.toLowerCase();
    $$(".tasks div.task").each(function (t) {
      if (t.down('a.name').innerHTML.toLowerCase().match(name)) {
        if (show) {
          t.show();
        } else {
          t.hide();
        }
      }
    });
    return TasksHelper;
  };

  // expose
  Teambox.helpers.tasks = TasksHelper;

}());
