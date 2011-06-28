(function () {

  var FilterDueDate = { tagName: 'select'
                      , id: 'filter_due_date'
                        // TODO: generate this with task::status
                      , options_html: '<option value="">Anytime</option>'
                                    + '<option value="overdue">Late tasks</option>'
                                    + '<option value="unassigned_date">No date assigned</option>'
                                    + '<option value="divider" disabled="disabled">------</option>'
                                    + '<option value="due_today">Today</option>'
                                    + '<option value="due_tomorrow">Tomorrow</option>'
                                    + '<option value="due_week">This week</option>'
                                    + '<option value="due_2weeks">Next 2 weeks</option>'
                                    + '<option value="due_3weeks">Next 3 weeks</option>'
                                    + '<option value="due_month">Within 1 month</option>' };

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
