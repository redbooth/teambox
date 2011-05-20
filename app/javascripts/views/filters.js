(function () {

  var Filters = {
    className: 'filters'
  };

  Filters.initialize = function (options) {
    this.filters = options.filters;
    this.task_list = options.task_list;

    _.bindAll(this, 'render');
  };

  Filters.render = function () {
    var el = this.el
      , self = this;

    this.el.insert((new Element('strong')).update('Filter tasks:'));

    _.each(this.filters, function (filter) {
      var constructor = 'Filter' + _.camelize(_.capitalize(filter))
        , fil = new Teambox.Views[constructor]({task_list: self.task_list});
      el.insert(fil.render().el);
    });

    return this;
  };

  // expose
  Teambox.Views.Filters = Backbone.View.extend(Filters);

}());
