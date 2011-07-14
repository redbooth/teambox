(function () {
  var DropDown = {};

  DropDown.initialize = function (options) {
    _.bindAll(this, 'render');
    this.collection = options.collection;
    this.tagName = options.tagName || 'div';
    this.className = options.className || 'dropdown';
  };

  DropDown.events = {
      'keydown input[type=text]': 'navigateSelect'
    , 'keyup input[type=text]':   'filterOptions'
    , 'click li':                 'selectEvent'
  };

  DropDown.render = function () {
    var self = this;

    this.reset();
    this.setupBlurFocusHandlers();
    this.selectOption(this.collection.first());
  };

  DropDown.setupBlurFocusHandlers = function() {
    this.el.down('input[type=text]').on('focus', this.showDropDown.bind(this));
    this.el.down('input[type=text]').on('blur', this.hideDropDown.bind(this));
  };

  DropDown.showDropDown = function(event) {
    var dropDown = this.el.down('.dropdown_autocomplete');
    if (dropDown.getStyle('display') === 'none') {
      dropDown.setStyle({display: 'block'});
      this.el.down('.dropdown_arrow').setStyle({'background-position': '-93px 0px'});
    }
  };

  DropDown.hideDropDown = function(event) {
    var dropDown = this.el.down('.dropdown_autocomplete');
    if (dropDown.getStyle('display') === 'block') {
      dropDown.setStyle({display: 'none'});
      this.el.down('.dropdown_arrow').setStyle({'background-position': '0px 0px'});
    }
  };

  DropDown.updateOptions = function(collection) {
    this.el.down('.dropdown_autocomplete').update(collection.reduce(function (memo, entry) {
      memo += '<li data-entry-id="'  + entry.id + '">';
      memo += entry.value + '</li>';
      return memo;
    }, ''));
  };

  DropDown.selectOption = function(entry) {
    this.el.down('input[type=hidden]').value = entry.id;
    this.el.down('input[type=text]').value = entry.value;
  };

  DropDown.selectEvent = function(event, li) {
    event.stop();
    li = li || event.target;

    var entry = _.detect(this.collection, function(e) { return e.id === li.getAttribute('data-entry-id');});
    this.selectElement(li);
    this.selectOption(entry);
  };

  DropDown.selectElement = function(li) {
    li.addClassName('selected');
  };

  DropDown.reset = function() {
    this.updateOptions(this.collection);
  };

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
      var li = this.el.down('.dropdown_autocomplete li.selected');
      this.selectEvent(event, li);
      return false;
    }
    else {
      var search_term = this.el.down('input[type=text]').value;

      if (search_term.length) {
        this.updateOptions(this.collection.select(function(entry){
          return entry.value.toLowerCase().startsWith(search_term.toLowerCase());
        }));
      }
      else {
        this.reset();
      }
    }
  };

  DropDown.navigateSelect = function(event) {
    this.showDropDown();

    if (event.keyCode === Event.KEY_RETURN) {
      event.stop();
      return false;
    }
    // Prevent up/down cursor actions on the input
    else if (event.keyCode === Event.KEY_UP) {
      var li = this.el.down('.dropdown_autocomplete li.selected');
      if (li) {
        var prev = li.previous('li');
        if (prev) {
          li.removeClassName('selected');
          prev.addClassName('selected');
        }
      }
      return event.stop();
    }
    else if (event.keyCode === Event.KEY_DOWN) {
      var li = this.el.down('.dropdown_autocomplete li.selected');
      if (!li) {
        li = this.el.select('.dropdown_autocomplete li').first();
        li.addClassName('selected');
      }
      else {
        var next = li.next('li');
        if (next) { 
          li.removeClassName('selected');
          next.addClassName('selected');
        }
      }

      return event.stop();
    }
  };

  // expose
  Teambox.Views.DropDown = Backbone.View.extend(DropDown);

}());
