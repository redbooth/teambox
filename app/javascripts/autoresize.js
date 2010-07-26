document.on('keyup', 'textarea[name*="[body]"]', function(e, area) {
  area.resizeToText(false)
});

document.on('keyup', 'textarea[name*="[description]"]', function(e, area) {
  area.resizeToText(false)
});
