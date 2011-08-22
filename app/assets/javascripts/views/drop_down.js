(function () {
  var DropDown = {};

  /* Initialise a new DropDown view
   *
   * Allows you to selection from a list of options
   * Using either keyboard or mouse
   * and filters list as you type.
   *
   * @param {Object} options
   * @required options.collection
   * @optional options.tagName
   * @optional options.className
   *
   * Expects the following markup:
   *   input(type="hidden")
   *   input(type="text")
   *   a.dropdown_arrow
   *   ol.dropdown_autocomplete
   */
  DropDown.initialize = function (options) {
    _.bindAll(this, 'render');
    this.collection = options.collection;
    this.tagName = options.tagName || 'div';
    this.className = options.className || 'dropdown';
    this.selected = options.selected;
  };

  DropDown.events = {
      'keydown input[type=text]': 'navigateSelect'
    , 'keyup input[type=text]':   'filterOptions'
    , 'click li': 'selectEvent'
    , 'click .dropdown_arrow': 'showDropDown'
    , 'mouseover li': 'selectElement'
  };

  /* Updates current el
   *
   * @return self
   */
  DropDown.render = function () {
    var self = this;

    this.reset();
    this.setupBlurFocusHandlers();

    if (this.selected) {
      this.selectOption(this.selected);
    }
    else {
      this.selectFirstEntry();
    }
    return this;
  };

  /* Select the first entry in the collection
   * if the text input is empty or
   * if there's no value in the text input that corresponds
   * an entry in the collection.
   */
  DropDown.selectFirstEntry = function() {
    var label = this.$('input[type=text]').val();

    if (!label || !label.length) {
      this.selectOption(_.toArray(this.collection)[0]);
    }
    else if (!_.any(this.collection, function(entry){
      return entry.label.toLowerCase() === label.toLowerCase();
    })) {
      this.selectOption(_.toArray(this.collection)[0]);
    }
  };

  /* Show/hide dropdown on focus/blur
   * On blur event, hide is triggered in a timeout
   * so as not to conflict with click event.
   * Will also call selectFirstEntry on blur event
   */
  DropDown.setupBlurFocusHandlers = function() {
    this.$('input[type=text]').bind('focus', this.showDropDown.bind(this));
    this.$('input[type=text]').bind('blur', function(event) {
      setTimeout(this.hideDropDown.bind(this), 1000)
      this.selectFirstEntry();
    }.bind(this));
  };

  /* Show dropdown
   *
   * @param {Object} event
   */
  DropDown.showDropDown = function(event) {
    var dropDown = this.$('.dropdown_autocomplete');
    if (dropDown.css('display') === 'none') {
      dropDown.css({display: 'block'});
      this.$('.dropdown_arrow').css({'background-position': '-93px 0px'});
    }
  };

  /* Hide dropdown
   *
   * @param {Object} event
   */
  DropDown.hideDropDown = function(event) {
    var dropDown = this.$('.dropdown_autocomplete');
    if (dropDown.css('display') === 'block') {
      dropDown.css({display: 'none'});
      this.$('.dropdown_arrow').css({'background-position': '0px 0px'});
    }
  };

  /* Render dropdown options from supplied collection.
   *
   * @param {Array} collection
   */
  DropDown.updateOptions = function(collection) {
    this.$('.dropdown_autocomplete').html(_.reduce(collection, function (memo, entry) {
      memo += '<li data-entry-id="'  + entry.value + '"><span class="entry">';
      memo += entry.label + '</span></li>';
      return memo;
    }, ''));
  };

  /* Write selected option to form fields
   *
   * @param {Object} entry
   */
  DropDown.selectOption = function(entry) {
    this.$('input[type=hidden]').val(entry.value);
    this.$('input[type=text]').val(entry.label);
    this.trigger('change:selection', entry.value);
  };

  /* Handles selecting an entry either via click or return key
   *
   * @param {Object} event
   * @param {Object} li
   */
  DropDown.selectEvent = function(event, li) {
    event.preventDefault();
    li = li || event.target;

    var entry = _.detect(this.collection, function(e) { return e.value.toString() === li.getAttribute('data-entry-id');});
    this.selectElement(false, li);
    this.selectOption(entry);
    if (event.type === 'click') {
      this.hideDropDown();
    }
  };

  /* Highlight selected li element.
   *
   * @param {Object} event
   * @param {Object} li
   */
  DropDown.selectElement = function(event, li) {
    this.$('li').removeClass('selected');
    jQuery(event.target || li).addClass('selected');
  };

  /* Rerender list with full collection
   */
  DropDown.reset = function() {
    this.updateOptions(this.collection);
  };

  /* Filter list on key up according to wether
   * value of text input begins with an entry or not
   *
   * Handle return key and selection target option
   *
   * @param {Object} event
   */
  DropDown.filterOptions = function(event) {
    if (event.keyCode === Event.KEY_DOWN) {
      event.stop();
      return false;
    }
    else if (event.keyCode === Event.KEY_UP) {
      event.stop();
      return false;
    }
    else if (event.keyCode === Event.KEY_ESC) {
      this.hideDropDown();
      event.stop();
      return false;
    }
    else if (event.keyCode === Event.KEY_RETURN) {
      event.stop();
      var li = this.$('.dropdown_autocomplete li.selected');
      this.selectEvent(event, li);
      return false;
    }
    else {
      var search_term = this.$('input[type=text]').val();

      if (search_term.length) {
        this.updateOptions(_.select(this.collection, function(entry){
          return entry.label.toLowerCase().startsWith(search_term.toLowerCase());
        }));
      }
      else {
        this.reset();
      }
    }
  };

  /* Enable moving up and down the list with the arrow keys
   *
   * @param {Object} event
   */
  DropDown.navigateSelect = function(event) {
    this.showDropDown();

    if (event.keyCode === Event.KEY_RETURN) {
      event.preventDefault();
      return false;
    }
    // Prevent up/down cursor actions on the input
    else if (event.keyCode === Event.KEY_UP) {
      var li = this.$('.dropdown_autocomplete li.selected');
      if (li.length) {
        var prev = li.prev('li');
        if (prev.length) {
          li.removeClass('selected');
          prev.addClass('selected');
        }
      }
      return event.preventDefault();
    }
    else if (event.keyCode === Event.KEY_DOWN) {
      var li = this.$('.dropdown_autocomplete li.selected');
      if (!li.length) {
        li = this.$('.dropdown_autocomplete li').eq().addClass('selected');
      }
      else {
        var next = li.next('li');
        if (next.length) { 
          li.removeClass('selected');
          next.addClass('selected');
        }
      }

      return event.preventDefault();
    }
  };

  // expose
  Teambox.Views.DropDown = Backbone.View.extend(DropDown);

}());
