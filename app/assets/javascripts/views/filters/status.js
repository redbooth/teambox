(function () {

  var FilterStatus = { tagName: 'select'
                     , id: 'filter_status'
                     , options_html: '<option value="">All status</option>'
                                   + '<option value="status_0">New</option>'
                                   + '<option value="status_1">Open</option>'
                                   + '<option value="status_2">Hold</option>'
                                   + '<option value="status_3">Resolved</option>'
                                   + '<option value="status_4">Rejected</option>' };

  FilterStatus.initialize = function (options) {
    var el = $(this.el);

    this.filters = options.filters;
    this.task_list = this.filters.task_list;
    el.update(this.options_html);
    _.bindAll(this, 'render');
    el.observe('change', FilterStatus.filterTasks.bind(this));
  };

  FilterStatus.render = function () {
    return this;
  };

  FilterStatus.filterTasks = function () {
    this.filters.filter('status', this.el.value);
  };

  // expose
  Teambox.Views.FilterStatus = Backbone.View.extend(FilterStatus);

}());
