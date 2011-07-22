(function () {
  var ViewsHelper = {};

  /* Delegate events to a specific element.
   *
   * Note: Unbinds any events on the root element (this.el).
   *
   * @return self
   */
  ViewsHelper.delegateEventsTo = function(events, el) {
    var eventSplitter = /^(\w+)\s*(.*)$/;

    $(this.el).stopObserving();

    if (!(events || (events = this.events))) return;
    this._registeredEvents = this._registeredEvents || [];
    _(this._registeredEvents).each(function(e) {
      e.stop();
    });
    for (var key in events) {
      var methodName = events[key];
      var match = key.match(eventSplitter);
      var eventName = match[1], selector = match[2];
      var method = _.bind(this[methodName], this);
      if (selector === '') {
        var evt = $(el).on(eventName, method);
      } else {
        var evt = $(el).on(eventName, selector, method);
      }
      this._registeredEvents.push(evt);
    }

    return this;
  };

  // exports
  Teambox.helpers.views = ViewsHelper;

}());

