(function () {

  var FilterName = {
    tagName: 'input'
  , className: 'filter_tasks_by_name'
  , placeholder: 'By name'
  };

  FilterName.initialize = function (options) {
    var el = $(this.el);
    el.writeAttribute('type', 'search');
    el.writeAttribute('placeholder', this.placeholder);

    _.bindAll(this, 'render');

    el.observe('keyup', _.throttle(FilterName.updateTasks.bind(this), 200));
  };

  FilterName.render = function () {
    return this;
  };

  FilterName.updateTasks = function () {
    var el = $(this.el);

    if (el.value !== '' && el.value !== this.placeholder) {
      Teambox.helpers.tasks
        .showAllTaskLists()
        .hideAllTasks()
        .displayByName(el.value, true);
    }

    Teambox.helpers.tasks.foldEmptyTaskLists();
  };

  // expose
  Teambox.Views.FilterName = Backbone.View.extend(FilterName);

}());
