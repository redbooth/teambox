(function () {

  var Filters = { className: 'filters' }
    , TasksHelper = Teambox.helpers.tasks;

  Filters.initialize = function (options) {
    var self = this;

    this.filters = options.filters || {};
    this.task_list = options.task_list;
    this.views = {};

    _.each(Object.keys(this.filters), function (filter) {
      self.views[filter] = new Teambox.Views['Filter' + _.camelize(_.capitalize(filter))]({filters: self});
    });

    _.bindAll(this, 'render');
  };

  Filters.render = function () {
    var view;

    this.el.insert((new Element('strong')).update('Filter tasks:'));

    for (view in this.views) {
      this.el.insert(this.views[view].render().el);
    }

    // filter if any filter has been initialized
    this.filter();

    return this;
  };

  /* Applies filters and hide/show the tasks according to it
   *
   * @param {String} filter
   * @param {String} value
   */
  Filters.filter = function (filter_name, value) {
    var tasks = $$(".tasks div.task")
      , filter, view;

    function getMethod(filter) {
      return 'select' + _.camelize(_.capitalize(filter));
    }

    if (filter_name) {
      this.filters[filter_name] = value;
      if (value) {
        tasks = TasksHelper[getMethod(filter_name)](tasks, value);
      }
    }

    for (filter in this.filters) {
      view = this.views[filter];

      if (view.tagName === 'select' && filter !== filter_name) {
        _.each(view.el.select('option'), function (option) {
          var count = option.value
                      ? TasksHelper[getMethod(filter)](tasks, option.value).length
                      : tasks.length;

          if (!option.disabled) {
            option.text = option.text.replace(/ \(.*?\)$/, '') + ' (' + count + ')';
          }
        });
      }
    }

    TasksHelper.showAllTaskLists().displayAllTasks(false);
    tasks.invoke('show');
    TasksHelper.foldEmptyTaskLists();
  };

  // expose
  Teambox.Views.Filters = Backbone.View.extend(Filters);

}());
