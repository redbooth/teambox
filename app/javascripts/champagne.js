/** Emulate "submit" and "change" events bubbling in IE
 */
;(function() {
  // Technique from Juriy Zaytsev
  // http://thinkweb2.com/projects/prototype/detecting-event-support-without-browser-sniffing/
  function isEventSupported(eventName) {
    var el = document.createElement('div');
    eventName = 'on' + eventName;
    var isSupported = (eventName in el);
    if (!isSupported) {
      el.setAttribute(eventName, 'return;');
      isSupported = typeof el[eventName] == 'function';
    }
    el = null;
    return isSupported;
  }
  
  function isForm(element) {
    return Object.isElement(element) && element.nodeName.toUpperCase() == 'FORM'
  }
  
  function isInput(element) {
    if (Object.isElement(element)) {
      var name = element.nodeName.toUpperCase()
      return name == 'INPUT' || name == 'SELECT' || name == 'TEXTAREA'
    }
    else return false
  }

  var submitBubbles = isEventSupported('submit'),
      changeBubbles = isEventSupported('change')
  
  if (!submitBubbles || !changeBubbles) {
    // augment the Event.Handler class to observe custom events when needed
    Event.Handler.prototype.initialize = Event.Handler.prototype.initialize.wrap(
      function(init, element, eventName, selector, callback) {
        init(element, eventName, selector, callback)
        // is the handler being attached to an element that doesn't support this event?
        if ( (!submitBubbles && this.eventName == 'submit' && !isForm(this.element)) ||
             (!changeBubbles && this.eventName == 'change' && !isInput(this.element)) ) {
          // "submit" => "emulated:submit"
          this.eventName = 'emulated:' + this.eventName
        }
      }
    )
  }
  
  if (!submitBubbles) {
    // discover forms on the page by observing focus events which always bubble
    document.on('focusin', 'form', function(focusEvent) {
      // special handler for the real "submit" event (one-time operation)
      if (!this.retrieve('emulated:submit')) {
        this.on('submit', function(submitEvent) {
          var emulated = this.fire('emulated:submit', submitEvent, true)
          // if custom event received preventDefault, cancel the real one too
          if (emulated.returnValue === false) submitEvent.preventDefault()
        })
        this.store('emulated:submit', true)
      }
    })
  }
  
  if (!changeBubbles) {
    // discover form inputs on the page
    document.on('focusin', 'input, select, texarea', function(focusEvent) {
      // special handler for real "change" events
      if (!this.retrieve('emulated:change')) {
        this.on('change', function(changeEvent) {
          this.fire('emulated:change', changeEvent, true)
        })
        this.store('emulated:change', true)
      }
    })
  }
})()
