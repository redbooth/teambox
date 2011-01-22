document.on('click', 'a.show_archived', function(e,el) {
  e.stop()
  el.hide()
  el.up().next('.archived_projects').blindDown({duration: 0.2})
})