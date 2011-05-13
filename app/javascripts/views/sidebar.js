(function () {

  var Sidebar = Backbone.View.extend({
    events: {
      "click .el" : "clickElement"
    }

  , initialize: function (options) {
      this.app = options.app;

      _.bindAll(this, 'renderTaskCounter');

      // TODO: bind only to change
      this.app.my_tasks.bind('all', this.renderTaskCounter);

      // Hide folded navigation bar elements
      $(this.el).select('.contained').invoke('hide');

      // Select and expand the current element
      var current = this.detectSelectedSection();
      if (current) {
        this.toggleElement(current);
        this.showContainers(current);
      }
    }

    /* renders the counters on the tasks sidebar
     *
     */
  , renderTaskCounter: function () {
      var mine  = this.app.my_tasks.mine()
        , today = this.app.my_tasks.today()
        , late  = this.app.my_tasks.late();

      $$("#my_tasks_link span, #today_link span").invoke('remove');


      if (mine && mine.length > 0) {
        $("my_tasks_link").insert({ bottom: "<span>" + mine.length + "</span>" });
      }

      if (today && today.length > 0) {
        $("today_link").insert({ bottom: "<span>" + today.length + "</span>" });
        if (late.length > 0) {
          $$("#today_link span")[0].addClassName('red');
        }
      }
    }

    /* handles on clicking a sidebar element
     *
     * @param {Event} e
     * @param {Element} el
     */
  , clickElement: function (e, el) {
      // Adding this to handle highlight for backboned links
      if (el.down('a.backboned')) {
        return;
      }

      if (this.toggleElement(el, true)) {
        e.stop();
      }
    }

    /* Selects the link in the sidebar according to the current url
     *
     * @return {Element} link selected
     *
     * TODO: Replace with controllers selecting the right element <= sure?
     */
  , detectSelectedSection: function () {
      // Direct match
      var links = $$('.nav_links a')
        , link = links.select(function (e) {
            return e.getAttribute('href') === window.location.hash;
          }).last();

      if (link) {
        return link.up('.el');
      } else {
        link = links.sortBy(function (e) {
          return e.getAttribute('href').length;
        }).select(function (e) {
          return (window.location.pathname.search(e.getAttribute('href')) > -1 && e.getAttribute('href') !== '/');
        }).last();

        return link.up('.el');
      }
    }

    /* Expand containers for this element, if it's under one
     *
     * @param {Element} element
     */
  , showContainers: function (element) {
      (function next(el) {
        var container = el.up();
        if (container.hasClassName('contained')) {
          container.show().previous('.el').addClassName('expanded');
        } else if (container.hasClassName('nav_links')) {
          return;
        }
        next(container);
      }(element));
    }

    /* Expand element containing others
     *
     * @param {Element} element
     * @param {Boolean} effect
     *
     * @return {Boolean} element should prevent an event
     */
  , toggleElement: function (element, effect) {
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
    }

    // Highlight this element, clearing others
  , selectElement: function (el) {
      $(this.el).select('.el.selected')
        .invoke('removeClassName', 'selected')
        .invoke('removeClassName', 'children-selected');
      el.addClassName('selected');
    }

  }
, { highlightSidebar: function (id) {
      // TODO: is there a global with app_controller?
      $app.sidebar_view.selectElement($(id), true);
  }
  });

  // expose
  Teambox.Views.Sidebar = Sidebar;
}());
