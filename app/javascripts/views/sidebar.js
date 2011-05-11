Teambox.Views.Sidebar = Backbone.View.extend({
  // Bind to the document's body, with the existing DOM
  //el: $('column'),

  // Initialize the sidebar
  initialize: function() {
    _.bindAll(this, 'renderTaskCounter');

    // TODO: bind only to change
    Teambox.my_tasks.bind('all', this.renderTaskCounter);

    // Hide folded navigation bar elements
    $(this.el).select('.contained').invoke('hide');

    // Select and expand the current element
    var current = this.detectSelectedSection();
    if (current) {
      this.toggleElement(current);
      this.showContainers(current);
    }
  },

  // Updates my tasks' counter
  renderTaskCounter: function() {
    $$("#my_tasks_link span, #today_link span").invoke('remove');

    var mine = Teambox.my_tasks.mine();
    var today = Teambox.my_tasks.today();
    var late = Teambox.my_tasks.late();

    if (mine && mine.length > 0) {
      $("my_tasks_link").insert({ bottom: "<span>"+mine.length+"</span>" });
    }
    if (today && today.length > 0) {
      $("today_link").insert({ bottom: "<span>"+today.length+"</span>" });
      if (Teambox.my_tasks.late().length > 0) {
        $$("#today_link span")[0].addClassName('red');
      }
    }
  },

  events: {
    "click .el"         : "clickElement"
  },

  // Handle clicks for the sidebar
  clickElement: function(e, el) {
    // Adding this to handle highlight for backboned links
    if (el.down('a.backboned')) { return; }
    if (this.toggleElement(el, true)) { e.stop(); }
  },

  // Try to highlight the loaded element link in the sidebar
  // TODO: Replace with controllers selecting the right element
  detectSelectedSection: function() {
    // Direct match
    var link = $$('.nav_links a').select(function(e) {
      return e.getAttribute('href') == window.location.pathname;
    }).last();
    if (link) { link.up('.el').addClassName('selected'); }
    // Close enough
    if (!link) {
      link = $$('.nav_links a').sortBy(function(e) {
        return e.getAttribute('href').length;
        }).select(function(e) {
          return (window.location.pathname.search(e.getAttribute('href')) > -1 && e.getAttribute('href') != '/');
      }).last();
      if (link) { link.up('.el').addClassName('children-selected'); }
    }

    if(link) { return link.up('.el'); }
  },

  // Expand containers for this element, if it's under one
  showContainers: function(current) {
    var container = current.up('.contained');
    if (container) {
      container.show().previous('.el').addClassName('expanded');
      // traverse up to find more containers
      while (container = container.up('.contained')) {
        container.show().previous('.el').addClassName('expanded');
      }
    }
  },

  // Expand an element containing others
  toggleElement: function(el, effect) {
    var contained = el.next();
    // if next element is an expanded area..
    if (contained && contained.hasClassName('contained')) {
      if (el.hasClassName('expanded')) {
        // contract it if it's open
        el.removeClassName('expanded');
        contained.setStyle({height: ''});
        contained.blindUp({ duration: 0.2 });
      } else {
        // contract others if open
        var visible_containers = el.up().select('.contained').select( function(e) { return e.visible(); });
        effect ? visible_containers.invoke("blindUp", { duration: 0.2 }) : visible_containers.invoke('hide');
        el.up().select('.el').invoke('removeClassName', 'expanded');
        // expand the selected one
        el.addClassName('expanded');

        contained.setStyle({height: ''});
        effect ? contained.blindDown({ duration: 0.2 }) : contained.show();
      }
      // Stop the event and don't follow the link
      return true;
    }
    // Stop the event if it's selected (don't follow the link)
    return el.hasClassName('selected');
  },

  // Highlight this element, clearing others
  selectElement: function(el) {
    $(this.el).select('.el.selected')
      .invoke('removeClassName', 'selected')
      .invoke('removeClassName', 'children-selected');
    el.addClassName('selected');
  }

});
