(function  () {

  var Filter = {
    assigned_options: []
  , due_date_options: []
  , cache: {}
  };

  Filter.init = function () {
    var filter_assigned = $("filter_assigned")
      , filter_due_date = $("filter_due_date");

    if (filter_assigned && Filter.assigned_options.length === 0) {
      Filter.assigned_options = Filter.getOptions(filter_assigned.options);
    }

    if (filter_due_date && Filter.due_date_options.length === 0) {
      Filter.due_date_options = Filter.getOptionsText(filter_due_date.options);
    }
  };

  /* shows all task_list containers
   * @return self
   */
  Filter.showAllTaskLists = function () {
    $$(".task_list_container").invoke('show');
    return Filter;
  };

  /* shows all tasks
   * @return self
   */
  Filter.showAllTasks = function () {
    $$(".tasks div.task").invoke('show');
    $$(".tasks.closed div.task").invoke('show');
    return Filter;
  };

  /* hides all tasks
   * @return self
   */
  Filter.hideAllTasks = function () {
    $$(".tasks div.task").invoke('hide');
    $$(".tasks.closed div.task").invoke('hide');
    return Filter;
  };

  /* gets all the tasks according a filter
   *
   * @param {String} assigned
   * @param {String} due_date
   *
   * @return {Array} filtered tasks
   */
  Filter.filterTasks = function (assigned, due_date) {
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
  Filter.showTasks = function (assigned, due_date) {
    Filter.hideAllTasks().filterTasks(assigned, due_date).invoke('show');
  };

  /* hides all the tasks according a filter
   *
   * @param {String} assigned
   * @param {String} due_date
   *
   * @return self
   */
  Filter.hideTasks = function (assigned, due_date) {
    Filter.showAllTasks().filterTasks(assigned, due_date).invoke('hide');
  };

  /* counts all the tasks according a filter
   *
   * @param {String} assigned
   * @param {String} due_date
   *
   * @return {Integer} number of matching tasks
   */
  Filter.countTasks = function (assigned, due_date) {
    return Filter.filterTasks(assigned, due_date).length;
  };

  /* Hides task lists if they don't have any visible tasks
   * @param {String} assigned
   * @param {String} due_date
   *
   * @retun self
   */
  Filter.foldEmptyTaskLists = function () {
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

    return Filter;
  };

  /* get an array of options
   *
   * @params @options
   * @return {Array} options
   */
  Filter.getOptions = function (options) {
    return _.reduce(options, function (out, option) {
      out.push({value: option.value, text: option.text, disabled: option.disabled, count: 0});
      return out;
    }, []);
  };

  /* get the an array of options text
   *
   * @params @options
   * @return {Array} options
   */
  Filter.getOptionsText = function (options) {
    return _.reduce(options, function (out, option) {
      out.push(option.text);
      return out;
    }, []);
  };

  /* updates tasks according to the filters
   *
   */
  Filter.updateTasks = function () {

    Filter.init();

    var assigned_options = Filter.assigned_options
      , due_date_options = Filter.due_date_options

      , filter_by_name = $("filter_tasks_by_name")
      , filter_assigned = $("filter_assigned")
      , filter_due_date = $("filter_due_date")

      , name, assigned, due_date, name_is_placeholder;

    if (filter_by_name === null && filter_assigned === null) {
      return;
    }

    name = filter_by_name.value;
    name_is_placeholder = (name === filter_by_name.readAttribute('placeholder'));
    assigned = filter_assigned.value === 'all' || !filter_assigned.value ? 'task' : filter_assigned.value;
    due_date = filter_due_date.value === 'all' || !filter_due_date.value ? null : filter_due_date.value;

    Filter.showAllTaskLists().hideAllTasks();

    // if its not filtered
    if ((name === "" || name_is_placeholder) && assigned === 'task' && filter_due_date === null) {
      Filter.showAllTasks();

    } else {
      // show by selection
      Filter.showTasks(assigned, due_date);

      // hide by name
      if (!name_is_placeholder) {
        Filter.hideByName(name);
      }
    }

    Filter.foldEmptyTaskLists().updateCounts({due_date: true});
  };

  /* hides tasks matching a name
   *
   * @param {String} name
   */
  Filter.hideByName = function (name) {
    name = name.toLowerCase();
    $$(".tasks div.task").each(function (t) {
      if (!t.down('a.name').innerHTML.toLowerCase().match(name)) {
        t.hide();
      }
    });
  };

  /* updates counts on the filter options
   *
   * @param {Object} options
   */
  Filter.updateCounts = function (options) {

    Filter.init();

    var assigned_options = Filter.assigned_options
      , due_date_options = Filter.due_date_options
      , filter_assigned = $("filter_assigned")
      , filter_due_date = $("filter_due_date")
      , idx = 0
      , current_assigned, assigned;

    if (filter_assigned === null) {
      return;
    }

    current_assigned = filter_assigned.value;
    assigned = (current_assigned === 'all' ? 'task' : filter_assigned.value);

    // update counts on assigned
    if (options.assigned) {
      filter_assigned.options.length = 0;

      _.each(assigned_options, function (option, i) {
        if (option.disabled) {
          filter_assigned.options[idx] = new Option(option.text, option.value);
          filter_assigned.options[idx].disabled = true;
          idx += 1;
        } else {
          var filter = (option.value === 'all' ? 'task' : option.value)
            , count = Filter.countTasks(filter, null);

          if (i < 3 || count > 0 || filter === current_assigned) {
            filter_assigned.options[idx] = (new Option(option.text + ' (' + count + ')', option.value));
            idx += 1;
          }
        }
      });

      filter_assigned.value = current_assigned;
    }

    // update counts on due_date
    if (options.due_date) {
      _.each(filter_due_date.options, function (option, i) {
        var filter = option.value === 'all' ? null : option.value;

        if (option.disabled) {
          return;
        }

        option.text = due_date_options[i] + ' (' + Filter.countTasks(assigned, filter) + ')';
      });
    }
  };

  Filter.populatePeopleForTaskFilter = function () {
    // TODO: what is _people?? the little people!
    if ((typeof _people === "object") && (select = $('filter_assigned'))) {
      select.insert(new Element('option', { 'value': 'divider', 'disabled': true}).insert('--------'))
      var users = []
      var user_ids = []
      if (project_id = select.readAttribute('data-project-id') && project_id != 0) {
        users = _people[project_id].collect(function  (e) { return [e[3],e[2]] })
      } else {
        (new Hash(_people)).values().each(function  (project) {
          project.each(function (person) {
            if (!user_ids.include(person[3])) {
              users.push([person[3],person[2]])
              user_ids.push(person[3])
            }
          })
        })
      }
      users.sortBy(function (e) { return e[1] }).each(function (user) {
        var option = new Element('option', { 'value': 'user_' + user[0]}).insert(user[1])
        select.insert(option)
      })
    }
  };

  // export
  Teambox.modules.Filter = Filter;

  // TODO: this should go to the view!
  document.on('keyup', '#filter_tasks_by_name', _.throttle(function (evt, el) {
    Filter.updateTasks();
  }, 200)); // throttling the function  improves performance

  // handles the "clear searchbox" event for webkit
  document.on('click', '#filter_tasks_by_name', function (evt, el) {
    Filter.updateTasks();
  });

  document.on("change", "#filter_tasks_by_name, #filter_assigned, #filter_due_date", function (evt, el) {
    var print_link = $$('.print_link').first();
    print_link.href = window.location.href + '.print?'
                                           + 'filter_assigned=' + $('filter_assigned').value
                                           + '&filter_due_date=' + $('filter_due_date').value
                                           + '&filter_tasks_by_name='  + $('filter_tasks_by_name').value;
    Filter.updateTasks();
  });

}());
