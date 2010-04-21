
document.on('keyup', 'textarea[name*="[body]"]', function(e) {
  var area = e.element()
  if (area.scrollHeight > area.clientHeight) {
    var wanted = area.getHeight() + (area.scrollHeight - area.clientHeight) + 15,
        available = document.viewport.getHeight() - area.viewportOffset().top - 60,
        possible = [wanted, available].min()
        
    area.setStyle({ height: possible + 'px' })
  }
});
