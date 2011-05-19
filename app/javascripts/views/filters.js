(function () {

  var Filters = {
    className: 'filters'
  };

  Filters.initialize = function (options) {
    this.filters = options.filters;

    _.bindAll(this, 'render');
  };

  Filters.render = function () {
    var el = this.el;

    this.el.insert((new Element('strong')).update('Filter tasks:'));

    _.each(this.filters, function (filter) {
      var fil = new Teambox.Views['Filter' + _.capitalize(filter)]();
      el.insert(fil.render().el);
    });

    return this;
  };

  // expose
  Teambox.Views.Filters = Backbone.View.extend(Filters);

}());
