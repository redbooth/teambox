(function () {

  var FilterAssigned = {
    tagName: 'select'
  , id: 'filter_assigned'
  , options_html: '<option value="all">anybody</option>'
                + '<option value="mine">my tasks</option>'
                + '<option value="unassigned">unassigned</option>'
  };

  FilterAssigned.initialize = function (options) {
    var el = $(this.el);

    this.task_list = options.task_list;
    el.update(this.options_html);
    _.bindAll(this, 'render');
    el.observe('change', FilterAssigned.filterTasks.bind(this));
  };

  FilterAssigned.render = function () {
    return this;
  };

  FilterAssigned.filterTasks = function () {
    var el = $(this.el)
      , value = el.value === 'all' || !el.value ? null : el.value;

    Teambox.helpers.tasks.filter.call(this.task_list, 'assigned', value);
  };

  // expose
  Teambox.Views.FilterAssigned = Backbone.View.extend(FilterAssigned);

}());
