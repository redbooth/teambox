Element.addMethods({
  resizeToText: function(area, force) {
    area = $(area)
    if (area.scrollHeight > area.clientHeight) {
      var wanted = area.getHeight() + (area.scrollHeight - area.clientHeight) + 15,
        available = document.viewport.getHeight() - area.viewportOffset().top - 60
      
      var possible = force ? wanted : Math.min(wanted, available)
      area.setStyle({ height: possible + 'px' })
    }
  }
})

var resizeLimited = Element.resizeToText.debounce(100)

document.on('keyup', 'textarea', function(e, area) {
  var doResize = function() { area.resizeToText(false) }
  
  if (e.keyCode == Event.KEY_RETURN) {
    Element.resizeToText.defer(area, false)
  } else {
    resizeLimited(area, false)
  }
})

document.on('facebox:opened', function() {
  $$('.facebox-content textarea').each(function(element){
    element.resizeToText(false)
  })
})
