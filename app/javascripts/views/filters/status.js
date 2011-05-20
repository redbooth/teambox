(function () {

  var FilterStatus = {
    tagName: 'select'
  , id: 'filter_status'
  , options_html: '<option value="">all status</option>'
                + '<option value="0">new</option>'
                + '<option value="1">open</option>'
                + '<option value="2">hold</option>'
                + '<option value="3">resolved</option>'
                + '<option value="4">rejected</option>'
  };

  FilterStatus.initialize = function (options) {
    var el = $(this.el);

    this.task_list = options.task_list;
    el.update(this.options_html);
    _.bindAll(this, 'render');
    el.observe('change', FilterStatus.filterTasks.bind(this));
  };

  FilterStatus.render = function () {
    return this;
  };

  FilterStatus.filterTasks = function () {
    var el = $(this.el)
      , value = el.value === 'all' || !el.value ? null : 'status_' + el.value;

    Teambox.helpers.tasks.filter.call(this.task_list, 'status', value);
  };

  // expose
  Teambox.Views.FilterStatus = Backbone.View.extend(FilterStatus);

}());
