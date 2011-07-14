(function () {
  var SelectProject = { tagName: 'div'
                        , className: 'dropdown_projects'
                      };

  SelectProject.initialize = function (options) {
    _.bindAll(this, 'render');
  };

  SelectProject.events = {
      'keydown input[type=text]': 'navigateSelect'
    , 'keyup input[type=text]':   'filterOptions'
    , 'click li':      'selectEvent'
  };

  SelectProject.render = function () {
    var self = this
    , ProjectsCollection = Teambox.collections.projects;

    this.reset();
    this.setupBlurFocusHandlers();
    this.selectOption(ProjectsCollection.models.first());
  };

  SelectProject.setupBlurFocusHandlers = function() {
    this.el.down('input[type=text]').on('focus', this.showDropDown.bind(this));
    this.el.down('input[type=text]').on('blur', this.hideDropDown.bind(this));
  };

  SelectProject.showDropDown = function(event) {
    var dropDown = this.el.down('.dropdown_autocomplete');
    if (dropDown.getStyle('display') === 'none') {
      dropDown.setStyle({display: 'block'});
      this.el.down('.dropdown_arrow').setStyle({'background-position': '-93px 0px'});
    }
  };

  SelectProject.hideDropDown = function(event) {
    var dropDown = this.el.down('.dropdown_autocomplete');
    if (dropDown.getStyle('display') === 'block') {
      dropDown.setStyle({display: 'none'});
      this.el.down('.dropdown_arrow').setStyle({'background-position': '0px 0px'});
    }
  };

  SelectProject.updateOptions = function(collection) {
    this.el.down('.dropdown_autocomplete').update(collection.reduce(function (memo, project) {
      memo += '<li data-project-id="'  + project.get('permalink') + '">';
      memo += project.get('name') + '</li>';
      return memo;
    }, ''));
  };

  SelectProject.selectOption = function(project) {
    this.el.down('input[type=hidden]').value = project.get('permalink');
    this.el.down('input[type=text]').value = project.get('name');
  };

  SelectProject.selectEvent = function(event, li) {
    event.stop();
    li = li || event.target;
    var ProjectsCollection = Teambox.collections.projects;

    var project = ProjectsCollection.getByPermalink(li.getAttribute('data-project-id'));
    this.selectElement(li);
    this.selectOption(project);
  };

  SelectProject.selectElement = function(li) {
    li.addClassName('selected');
  };

  SelectProject.reset = function() {
    var ProjectsCollection = Teambox.collections.projects;
    this.updateOptions(ProjectsCollection);
  };

  SelectProject.filterOptions = function(event) {
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
      var search_term = this.el.down('input[type=text]').value
      , ProjectsCollection = Teambox.collections.projects;

      if (search_term.length) {
        this.updateOptions(ProjectsCollection.select(function(project){
          return project.get('name').toLowerCase().startsWith(search_term.toLowerCase());
        }));
      }
      else {
        this.reset();
      }
    }
  };

  SelectProject.navigateSelect = function(event) {
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
  Teambox.Views.SelectProject = Backbone.View.extend(SelectProject);

}());
