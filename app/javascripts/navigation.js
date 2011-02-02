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
  }
}

document.on("dom:loaded", function() {
  $$('.nav_links .contained').invoke('hide')

  // Select and expand the current element
  var current = NavigationBar.detectSelectedSection()
  if (current) {
    // If it's hidden in the "Show more" options
    if(!current.visible()) {
      $('show_more').insert({before: current})
      current.show()
    }
    NavigationBar.toggleElement(current)
    NavigationBar.showContainers(current)
  }
  // If we're on All Projects, then expand the recent projects list
  var elements = $$('.nav_links .el')
  if (elements[0] && elements[0].hasClassName('selected')) {
    NavigationBar.toggleElement(elements[1])
  }
})

document.on('click', 'a#open_my_tasks', function(e,el) {
  if (e.isMiddleClick()) return
  e.stop()
  window.location = el.readAttribute("href")
})

document.on('click', '.nav_links .el', function(e,el) {
  if (e.isMiddleClick()) return
  NavigationBar.toggleElement(el, true) && e.stop()
})

document.on('click', '.nav_links .el .show_more', function(e,el) {
  e.stop()
  $$('.el#show_more').invoke('hide')
  $$('.el.extra').invoke('show')
})

document.on('click', '.nav_links .el .show_less', function(e,el) {
  e.stop()
  $$('.el#show_more').invoke('show')
  $$('.el.extra').invoke('hide')
})
