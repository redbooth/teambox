/*globals Templates*/
(function () {
  var TasksHelper = {};

  /* updated the element
   *
   * @return self
   */
  TasksHelper.render = function (options) {
    var self = this;

    if (options.tasks.length > 0) {
      this.el.update(options.template());

      options.tasks.each(function (task) {
        self.el.select('.tasks')[0].insert({bottom: (new Teambox.Views.Task({model: task})).render().el});
      });
    } else {
      this.el.update(options.primer_template());
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

  /* Delete all the groups
   *
   * @param {Array} tasks
   * @param {Object} options
   *
   * @return self
   */
  TasksHelper.ungroup = function (tasks) {
    $$('#content .group').invoke('remove');

    return TasksHelper;
  };

  /* Group tasks by...
   *
   * @param {Object} options
   *
   * @return self
   */
  TasksHelper.group = function (options) {
    // deletes previous groupings
    TasksHelper.ungroup();

    var sorted = TasksHelper.sort(options.tasks, options.by)
      , last_status = {order: null};

    _.each(sorted, function (el) {
      var current_status = TasksHelper.getStatus(options.by)(el);
      if (last_status.order !== current_status.order) {
        options.where.insert('<div class="group">' + current_status.label + '</div>');
      }
      options.where.insert({bottom: el});
      last_status = current_status;
    });

    return TasksHelper;
  };

  /* Sort tasks by...
   *
   * @param {Array} tasks
   * @param {String} by
   *
   * @return {Array} sorted elements
   */
  TasksHelper.sort = function (tasks, by) {
    return _.sortBy(tasks, TasksHelper.getStatus(by, 'order'));
  };

  /* Get task status by
   *
   * @param {String} by
   * @param {String} optional attr
   *
   * @return {Function} get status
   */
  TasksHelper.getStatus = function (by, attr) {
    var status = Teambox.Models.Task.status[by];
    switch (by) {
    case 'assigned':
    case 'due_date':
    case 'status':
      return function (task) {
        for (var key in status) {
          if (task.hasClassName(key)) {
            return attr ? status[key][attr] : status[key];
          }
        }
      };
    case 'task_list':
      return function (task) {
        var el = {
          order: +task.className.match(/task_list_([0-9])/)[1]
        , label: task.select('.project a')[0].textContent
        };
        return attr ? el[attr] : el;
      };
    }
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
