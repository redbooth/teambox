NavigationBar = {
  detectSelectedSection: function() {
    var link = $$('.nav_links a').detect(function(e) {
      return e.getAttribute('href') == window.location.pathname
    })
    if(link) return link.up('.el')
  },

  showContainers: function(current) {
    var container = current.up('.contained')
    if (container) {
      container.show()
      prev_container = container.up('.contained')
      prev_container && prev_container.show()
    }
  },

  toggleElement: function(el, effect) {
    var contained = el.next()
    // if next element is an expanded area..
    if (contained && contained.hasClassName('contained')) {
      if (el.hasClassName('expanded')) {
        // contract it if it's open
        el.removeClassName('expanded')
        contained.hide()
      } else {
        // contract others if open
        el.up().select('.contained').invoke('hide')
        el.up().select('.el').invoke('removeClassName', 'expanded')
        // expand the selected one
        el.addClassName('expanded')
        effect ? contained.blindDown({ duration: 0.2 }) : contained.show()
      }
      // Stop the event and don't follow the link
      return true
    }
    // Stop the event if it's selected (don't follow the link)
    return el.hasClassName('selected')
  },

  selectElement: function(el) {
    $$('.nav_links .el.selected').invoke('removeClassName', 'selected')
    el.addClassName('selected')
  }
}

document.on("dom:loaded", function() {
  $$('.nav_links .contained').invoke('hide')

  // Select and expand the current element
  var current = NavigationBar.detectSelectedSection()
  if (current) {
    current.addClassName('selected')
    NavigationBar.toggleElement(current)
    NavigationBar.showContainers(current)
  }
  // If we're on All Projects, then expand the recent projects list
  var elements = $$('.nav_links .el')
  if (elements[0].hasClassName('selected')) {
    NavigationBar.toggleElement(elements[1])
  }
})

document.on('click', '.nav_links .el', function(e,el) {
  if (e.isMiddleClick()) return
  NavigationBar.toggleElement(el, true) && e.stop()
})


// Load navigation elements on main view using AJAX
document.on('click', '.nav_links a.ajax', function(e,a) {
  if (e.isMiddleClick()) return
  e.stop()
  new Ajax.Request(a.readAttribute('href')+".frag", {
    method: "get",
    onLoading: function(r) { Loading.show() },
    onComplete: function(r) { Loading.hide() },
    onSuccess: function(r) {
      // Mark the new element as selected
      NavigationBar.selectElement(a.up('.el'))
      // Insert the content, and update posted dates if necessary
      $('content').update(r.responseText)
      format_posted_date()
      // Display the AJAX route in the navigation bar
      pushHistoryState(a.readAttribute('href'))
    },
    onFailure: function(r) {
      alert("Error while loading the page. Please try reloading the page.")
    }
  })
})