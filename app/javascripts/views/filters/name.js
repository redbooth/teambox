(function () {

  var FilterName = {
    tagName: 'input'
  , className: 'filter_tasks_by_name'
  , placeholder: 'By name'
  };

  FilterName.initialize = function (options) {
    var el = $(this.el);

    this.task_list = options.task_list;

    el.writeAttribute('type', 'search');
    el.writeAttribute('placeholder', this.placeholder);

    _.bindAll(this, 'render');

    el.observe('keyup', _.throttle(FilterName.filterTasks.bind(this), 200));
    // handles the "clear searchbox" event for webkit
    el.observe('click', _.throttle(FilterName.filterTasks.bind(this), 200));
  };

  FilterName.render = function () {
    return this;
  };

  FilterName.filterTasks = function () {
    var el = $(this.el)
      , has_value = (el.value !== '' && el.value !== this.placeholder);

    Teambox.helpers.tasks.filter.call(this.task_list, 'name', has_value ? el.value : null);
  };

  // expose
  Teambox.Views.FilterName = Backbone.View.extend(FilterName);

}());
