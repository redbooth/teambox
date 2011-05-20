(function () {

  var FilterStatus = { tagName: 'select'
                     , id: 'filter_status'
                     , options_html: '<option value="">all status</option>'
                                   + '<option value="0">new</option>'
                                   + '<option value="1">open</option>'
                                   + '<option value="2">hold</option>'
                                   + '<option value="3">resolved</option>'
                                   + '<option value="4">rejected</option>' };

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
