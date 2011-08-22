(function () {

  var Sidebar = {}
    , SidebarStatic = {};

  Sidebar.events = {
    'click .el' : 'clickElement'
  };

  Sidebar.initialize = function (options) {
    var current = SidebarStatic.detectSelectedSection(window.location.hash);

    _.bindAll(this, 'renderTaskCounter', 'renderProjects');

    // TODO: bind only to change
    Teambox.collections.tasks.bind('all', this.renderTaskCounter);
    Teambox.collections.projects.bind('all', this.renderProjects);

    // Render the projects if the view is initialized after loading the collection
    this.renderProjects();

    // Select and expand the current element
    if (current) {
      this.toggleElement(current);
      this.showContainers(current);
    }
  };

  /* renders the projects
   */
  Sidebar.renderProjects = function() {
    var projects = Teambox.collections.projects.models.collect( function(p) { return p.attributes });
    var html = Teambox.modules.ViewCompiler('sidebar.project')({ projects: projects });
    this.$(".projects_container").html(html);
  };

  /* renders the counters on the tasks sidebar
   */
  Sidebar.renderTaskCounter = function () {
    var mine  = Teambox.collections.tasks.mine()
      , today = Teambox.collections.tasks.today()
      , late  = Teambox.collections.tasks.late();

    this.$('#my_tasks_link span, #today_link span').remove();


    if (mine && mine.length) {
      this.$("#my_tasks_link").append('<span>' + mine.length + '</span>');
    }

    if (today && today.length) {
      this.$('#today_link').append('<span>' + today.length + '</span>');
      if (late.length) {
        this.$('#today_link span').addClass('red');
      }
    }
  };

  /* handles on clicking a sidebar element
   *
   * @param {Event} e
   * @param {Element} el
   */
  Sidebar.clickElement = function (e, el) {
    var el = jQuery(e.currentTarget);
    // Adding this to handle highlight for backboned links
    if (el.find('a.backboned').length) { return; }

    if (this.toggleElement(el, true)) {
      e.preventDefault();
    }
  };

  /* Expand containers for this element, if it's under one
   *
   * @param {Element} element
   */
  Sidebar.showContainers = function (element) {
    (function next(el) {
      var container = el.parent();
      if (container.hasClass('contained')) {
        container.show().prev('.el').addClass('expanded');
      } else if (container.hasClass('nav_links')) {
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
      , parent = element.parent();

    // if next element is an expandable area..
    if (next && next.hasClass('contained')) {
      if (element.hasClass('expanded')) {
        // contract it if it's open
        element.removeClass('expanded');
        next.css({height: ''}).slideUp(effect ? 200 : 0);
      } else {
        // contract others if open
        parent.find('.contained:visible').slideUp(effect ? 200 : 0);
        parent.find('.el').removeClass('expanded');

        // expand the selected one
        element.addClass('expanded');
        next.css({height: ''}).slideDown(effect ? 200 : 0);
      }

      return true;
    }

    return element.hasClass('selected');
  };

  // Highlight this element, clearing others
  Sidebar.selectElement = function (el) {
    this.$('.el.selected').removeClass('selected children-selected');

    el && el.addClass('selected');
  };

  // *class* methods
  SidebarStatic.highlightSidebar = function (id) {
    var el = (typeof id === "string") ? jQuery("#"+id) : jQuery(id);
    Teambox.views.sidebar.selectElement(el, true);
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
    var links = jQuery('.nav_links a')
      , link = jQuery(_(links).detect(function (e) {
          return jQuery(e).attr('href') === hash;
        }));

    if (link) {
      // return null if this link isn't contained inside a .el, or return the link
      var parent = link.parent('.el');
      return (parent.length === 0 ? null : parent);
    } else {
      link = _(links).chain()
      .sortBy(function (e) { return jQuery(e).attr('href').length; })
      .detect(function (e) {
        return (hash.search(jQuery(e).attr('href')) > -1 && jQuery(e).attr('href') !== '/');
      })
      .value();

      return link && link.parent('.el').length;
    }
  };

  // expose
  Teambox.Views.Sidebar = Backbone.View.extend(Sidebar, SidebarStatic);
}());
