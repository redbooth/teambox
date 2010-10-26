document.on('keyup', 'textarea', function(e, area) {
  area.resizeToText.defer(false)
}.debounce(200));

document.on('facebox:opened', function() {
  $$('.facebox-content textarea').each(function(element){
    element.resizeToText(false)
  })
})

Element.addMethods({
  resizeToText: function(area, force) {
    if (area.scrollHeight > area.clientHeight) {
      var wanted = area.getHeight() + (area.scrollHeight - area.clientHeight) + 15,
        available = document.viewport.getHeight() - area.viewportOffset().top - 60
      
      var possible = force ? wanted : Math.min(wanted, available)
      area.setStyle({ height: possible + 'px' })
    }
  }
})
