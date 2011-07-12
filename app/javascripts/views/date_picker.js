(function () {

  var DatePicker = { className: 'pick_date'
                   , template: Teambox.modules.ViewCompiler('partials.date_picker')
                   };

  DatePicker.events = {
    'click .date_picker' : 'showCalendar'
  };

  DatePicker.initialize = function (options) {
    _.bindAll(this, 'render');

    this.calendar_options = options.calendar_options || {
      buttons: true
    , popup: 'force'
    , time: false
    , year_range: [2008, 2020]
    };

    delete options.calendar_options;

    this.options = options;
  };

  /**
   * Updates the element using the template
   *
   * @return self
   */
  DatePicker.render = function () {
    this.el.update(this.template(this.options));
    return this;
  };

  /**
   * Displays the calendar
   *
   * @param {Event} evt
   * @param {DOM} element
   */
  DatePicker.showCalendar = function (evt, element) {
    evt.stop();

    new Teambox.modules.CalendarDateSelect(
      element.down('input')
    , element.down('span')
    , this.calendar_options);
  };

  // exports
  Teambox.Views.DatePicker = Backbone.View.extend(DatePicker);
}());
