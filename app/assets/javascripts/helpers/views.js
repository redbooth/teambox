(function () {
  var ViewsHelper = {};

  /* Delegate events to a specific element, instead of the default this.el
   *
   * Note: Unbinds any events on the root element (this.el).
   *
   * @return self
   */
  ViewsHelper.delegateEventsTo = function(events, el) {
    var eventSplitter = /^(\w+)\s*(.*)$/;

    jQuery(this.el).unbind();

    for (var key in events) {
      var methodName = events[key];
      var match = key.match(eventSplitter);
      var eventName = match[1], selector = match[2];
      var method = _.bind(this[methodName], this);
      if (selector === '') {
        jQuery(el).bind(eventName, method);
      } else {
        jQuery(el).delegate(selector, eventName, method);
      }
    }
    return this;
  };

  ViewsHelper.scrollTo = function(el, old_position) {
    var scrollable = $('container').down('.content_scroll')
    , center = Math.round(document.viewport.getDimensions().height / 2)
    , new_position = el ? el.cumulativeOffset().top - (80 + center) : scrollable.scrollTop;
    scrollable.scrollTop = old_position ? old_position : new_position;
  }

  // TODO: Not used?
  ViewsHelper.scrollableElement = function(el) {
    return jQuery('#container .content_scroll');
  }

  // exports
  Teambox.helpers.views = ViewsHelper;

}());

