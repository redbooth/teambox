(function () {

  var FilterDueDate = { tagName: 'select'
                      , id: 'filter_due_date'
                      , options_html: '<option value="">anytime</option>'
                                    + '<option value="overdue">late tasks</option>'
                                    + '<option value="unassigned_date">no date assigned</option>'
                                    + '<option value="divider" disabled="disabled">------</option>'
                                    + '<option value="due_today">today</option>'
                                    + '<option value="due_tomorrow">tomorrow</option>'
                                    + '<option value="due_week">this week</option>'
                                    + '<option value="due_2weeks">next 2 weeks</option>'
                                    + '<option value="due_3weeks">next 3 weeks</option>'
                                    + '<option value="due_month">within 1 month</option>' };

  FilterDueDate.initialize = function (options) {
    var el = $(this.el);

    this.filters = options.filters;
    this.task_list = this.filters.task_list;
    el.update(this.options_html);
    _.bindAll(this, 'render');
    el.observe('change', FilterDueDate.filterTasks.bind(this));
  };

  FilterDueDate.render = function () {
    return this;
  };

  FilterDueDate.filterTasks = function () {
    this.filters.filter('due_date', this.el.value);
  };

  // expose
  Teambox.Views.FilterDueDate = Backbone.View.extend(FilterDueDate);

}());
