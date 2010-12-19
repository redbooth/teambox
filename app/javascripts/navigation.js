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

  toggleElement: function(el) {
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
        contained.show()
      }
      return true
    }
    return false
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
})

document.on('click', '.nav_links .el', function(e,el) {
  if (e.isMiddleClick()) return
  NavigationBar.toggleElement(el) && e.stop()
})