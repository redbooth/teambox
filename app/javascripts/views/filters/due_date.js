(function () {

  var FilterDueDate = {
    tagName: 'select'
  , id: 'filter_due_date'
  , options_html: '<option value="all">anytime</option>'
                + '<option value="overdue">late tasks</option>'
                + '<option value="unassigned_date">no date assigned</option>'
                + '<option value="">------</option>'
                + '<option value="due_today">today</option>'
                + '<option value="due_tomorrow">tomorrow</option>'
                + '<option value="due_week">this week</option>'
                + '<option value="due_2weeks">next 2 weeks</option>'
                + '<option value="due_3weeks">next 3 weeks</option>'
                + '<option value="due_month">within 1 month</option>'
  };

  FilterDueDate.initialize = function (options) {
    var el = $(this.el);

    this.task_list = options.task_list;
    el.update(this.options_html);
    _.bindAll(this, 'render');
    el.observe('change', FilterDueDate.filterTasks.bind(this));
  };

  FilterDueDate.render = function () {
    return this;
  };

  FilterDueDate.filterTasks = function () {
    var el = $(this.el)
      , value = el.value === 'all' || !el.value ? null : el.value;

    Teambox.helpers.tasks.filter.call(this.task_list, 'due_date', value);
  };

  // expose
  Teambox.Views.FilterDueDate = Backbone.View.extend(FilterDueDate);

}());
