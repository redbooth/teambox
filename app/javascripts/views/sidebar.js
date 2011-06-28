(function () {

  var Sidebar = {}
    , SidebarStatic = {};

  Sidebar.events = {
    'click .el' : 'clickElement'
  };

  Sidebar.initialize = function (options) {
    var current = SidebarStatic.detectSelectedSection(window.location.hash);

    _.bindAll(this, 'renderTaskCounter');

    // TODO: bind only to change
    Teambox.collections.tasks.bind('all', this.renderTaskCounter);

    // Hide folded navigation bar elements
    $(this.el).select('.contained').invoke('hide');

    // Select and expand the current element
    if (current) {
      this.toggleElement(current);
      this.showContainers(current);
    }
  };

  /* renders the counters on the tasks sidebar
   */
  Sidebar.renderTaskCounter = function () {
    var mine  = Teambox.collections.tasks.mine()
      , today = Teambox.collections.tasks.today()
      , late  = Teambox.collections.tasks.late();

    $$('#my_tasks_link span, #today_link span').invoke('remove');


    if (mine && mine.length) {
      $("my_tasks_link").insert({bottom: '<span>' + mine.length + '</span>'});
    }

    if (today && today.length) {
      $('today_link').insert({bottom: '<span>' + today.length + '</span>'});
      if (late.length > 0) {
        $$('#today_link span')[0].addClassName('red');
      }
    }
  };

  /* handles on clicking a sidebar element
   *
   * @param {Event} e
   * @param {Element} el
   */
  Sidebar.clickElement = function (e, el) {
    // Adding this to handle highlight for backboned links
    if (el.down('a.backboned')) {
      return;
    }

    if (this.toggleElement(el, true)) {
      e.stop();
    }
  };

  /* Expand containers for this element, if it's under one
   *
   * @param {Element} element
   */
  Sidebar.showContainers = function (element) {
    (function next(el) {
      var container = el.up();
      if (container.hasClassName('contained')) {
        container.show().previous('.el').addClassName('expanded');
      } else if (container.hasClassName('nav_links')) {
        return;
      }
      next(container);
    }(element));
  };

  /* Expand element containing others
   *
   * @param {Element} element
   * @param {Boolean} effect
   *
   * @return {Boolean} element should prevent an event
   */
  Sidebar.toggleElement = function (element, effect) {
    var next = element.next()
      , parent = element.up()
      , visible_containers;

    // if next element is an expandable area..
    if (next && next.hasClassName('contained')) {
      if (element.hasClassName('expanded')) {
        // contract it if it's open
        element.removeClassName('expanded');
        next.setStyle({height: ''});
        if (effect) {
          next.blindUp({ duration: 0.2 });
        } else {
          next.hide();
        }
      } else {
        // contract others if open
        visible_containers = parent.select('.contained').select(function (e) {
          return e.visible();
        });

        if (effect) {
          visible_containers.invoke("blindUp", { duration: 0.2 });
        } else {
          visible_containers.invoke('hide');
        }
        parent.select('.el').invoke('removeClassName', 'expanded');

        // expand the selected one
        element.addClassName('expanded');
        next.setStyle({height: ''});
        if (effect) {
          next.blindDown({ duration: 0.2 });
        } else {
          next.show();
        }
      }

      return true;
    }

    return element.hasClassName('selected');
  };

  // Highlight this element, clearing others
  Sidebar.selectElement = function (el) {
    $(this.el).select('.el.selected')
      .invoke('removeClassName', 'selected')
      .invoke('removeClassName', 'children-selected');

    if (el) {
      el.addClassName('selected');
    }
  };

  // *class* methods
  SidebarStatic.highlightSidebar = function (id) {
    Teambox.views.sidebar.selectElement($(id), true);
  };

  /* Selects the link in the sidebar according to the current url
   *
   * @return {Element} link selected
   *
   * TODO: Replace with controllers selecting the right element <= sure?
   *
   *       Sure? we could do a mixed solution, this autoselects
   *       according to a url, and if a link was not found, we can force it
   *       from the controller by using `toggleElement` and|or `showContainers`
   */
  SidebarStatic.detectSelectedSection = function (hash) {
    // Direct match
    var links = $$('.nav_links a')
      , link = links.select(function (e) {
          return e.getAttribute('href') === hash;
        }).last();

    if (link) {
      return link.up('.el');
    } else {
      link = links.sortBy(function (e) {
        return e.getAttribute('href').length;
      }).select(function (e) {
        return (hash.search(e.getAttribute('href')) > -1 && e.getAttribute('href') !== '/');
      }).last();

      return link && link.up('.el');
    }
  };

  // expose
  Teambox.Views.Sidebar = Backbone.View.extend(Sidebar, SidebarStatic);
}());
