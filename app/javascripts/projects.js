document.on('click', 'a.show_archived', function(e,el) {
  e.stop()
  $$('.show_archived').invoke('hide')
  $$('.archived_projects').invoke('blindDown', {duration: 0.2})
})