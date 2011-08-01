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

  ViewsHelper.scrollTo = function(el, old_position) {
    var scrollable = $('container').down('.content_scroll')
    , center = Math.round(document.viewport.getDimensions().height / 2)
    , new_position = el ? el.cumulativeOffset().top - (80 + center) : scrollable.scrollTop;
    scrollable.scrollTop = old_position ? old_position : new_position;
  }

  ViewsHelper.scrollableElement = function(el) {
    return $('container').down('.content_scroll');
  }

  // exports
  Teambox.helpers.views = ViewsHelper;

}());

