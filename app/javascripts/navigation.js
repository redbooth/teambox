// UI for the Navigation Bar in the sidebar

NavigationBar = {
  detectSelectedSection: function() {
    // Direct match
		var link = $$('.nav_links a').select(function(e) {
			return e.getAttribute('href') == window.location.pathname
		}).last()
		if (link) link.up('.el').addClassName('selected')
		// Close enough
		if (link == undefined) {
			var link = $$('.nav_links a').sortBy(function(e) {
				return e.getAttribute('href').length
				}).select(function(e) {
					return (window.location.pathname.search(e.getAttribute('href')) > -1 && e.getAttribute('href') != '/')
			}).last()
			if (link) link.up('.el').addClassName('children-selected')
		}

    if(link) return link.up('.el')
  },

  showContainers: function(current) {
    var container = current.up('.contained')
    if (container) {
      container.show().previous('.el').addClassName('expanded')
      while (container = container.up('.contained')) {
				container.show().previous('.el').addClassName('expanded')
			}
    }
  },

  scroll: function() {
    var sidebar = $('column')
    var column = sidebar.up('.column_wrap')
    if (document.viewport.getHeight() > sidebar.getHeight() && document.viewport.getScrollOffsets()[1] >= NavigationBar.initial_offset) {
      sidebar.style.position = 'fixed'
      sidebar.style.top = 0
    }
    else
    {
      sidebar.style.position = 'absolute'
      sidebar.style.top = 'auto'
      column.style.height=sidebar.getHeight()+'px'
    }

  },

  scrollToTopIfNeeded: function() {
    var sidebar = $('column')
    if (document.viewport.getHeight() < sidebar.getHeight()) {
      NavigationBar.scroll()
      Effect.ScrollTo('container', { duration: '0.4' })
    }
  },

  toggleElement: function(el, effect) {
    var contained = el.next()
    // if next element is an expanded area..
    if (contained && contained.hasClassName('contained')) {
      if (el.hasClassName('expanded')) {
        // contract it if it's open
        el.removeClassName('expanded')
        contained.setStyle({height: ''})
        contained.blindUp({ duration: 0.2 })
      } else {
        // contract others if open
        var visible_containers = el.up().select('.contained').select( function(e) { return e.visible() })
        effect ? visible_containers.invoke("blindUp", { duration: 0.2 }) : visible_containers.invoke('hide')
        el.up().select('.el').invoke('removeClassName', 'expanded')
        // expand the selected one
        el.addClassName('expanded')

        contained.setStyle({height: ''})
        effect ? contained.blindDown({ duration: 0.2 }) : contained.show()
        setTimeout(function() { NavigationBar.scrollToTopIfNeeded() }, 100)
      }
      // Stop the event and don't follow the link
      return true
    }
    // Stop the event if it's selected (don't follow the link)
    return el.hasClassName('selected')
  },

  selectElement: function(el) {
    $$('.nav_links .el.selected').invoke('removeClassName', 'selected').invoke('removeClassName', 'children-selected')
    el.addClassName('selected')
  },

  loadProjectsSidebar: function() {
    var active_projects = $H(my_projects).select(function(p) { return !p[1].archived; });
    var projects_to_show = active_projects;
    var show_more = ($H(my_projects).size() > 0);
    if (projects_to_show.size() > 3) {
      projects_to_show = projects_to_show.select(function(p) { return my_user.recent_projects.include(p[0]); })
    }
    var projects = projects_to_show.collect(function(p) {
      return { name: p[1].name
             , permalink: p[1].permalink
             , time_tracking: p[1].time_tracking
             , owner: (p[1].owner == my_user.id) // Owner?
             , can_admin: (p[1].role == "3") // Admin?
      };
    })
    $('my_projects').down('span').update(active_projects.size());
    $('my_projects_list').update(Mustache.to_html(Templates.navigation.project, { projects: projects, show_more: show_more, new_project: my_user.can_create_project }));
  },

  loadOrganizationsSidebar: function() {
    var organizations = my_organizations.collect(function(o) {
      return { name: o.name , permalink: o.permalink, can_admin: (o.role == 30) };
    });
    $('my_organizations_list').update(Mustache.to_html(Templates.navigation.organizations, {
      organizations: organizations, no_community: !my_user.community
    }));
  }
}

document.on("dom:loaded", function() {
  NavigationBar.loadProjectsSidebar()
  NavigationBar.loadOrganizationsSidebar()
  $$('.nav_links .contained').invoke('hide')
  var column = window.$('column')
  if (!column)
    return

  column.style.position='absolute'
  NavigationBar.initial_offset = document.viewport.getScrollOffsets()[1] + column.viewportOffset().top

  // Select and expand the current element
  var current = NavigationBar.detectSelectedSection()
  if (current) {
    NavigationBar.toggleElement(current)
    NavigationBar.showContainers(current)
  }
  // If we're on All Projects, then expand the recent projects list
  var elements = $$('.nav_links .el')
  if (elements[0] && elements[0].hasClassName('selected')) {
    NavigationBar.toggleElement(elements[1])
  }
})

document.on('click', '.nav_links .el', function(e,el) {
  if (e.isMiddleClick()) return
  var clicked = Event.element(e)
  if (clicked.id == 'open_my_tasks') {
    window.location = clicked.readAttribute("href")
    e.stop()
  } else {
    NavigationBar.toggleElement(el, true) && e.stop()
  }
})

document.on('click', '.nav_links .el#show_all_projects', function(e,el) {
  if (e.isMiddleClick()) return
  e.stop()
  Projects.showAllProjects()
})

window.onscroll = function() { NavigationBar.scroll() }

