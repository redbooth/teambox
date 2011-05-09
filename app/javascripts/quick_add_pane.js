document.on('click', 'a.quick_add_link', function(e, el) {
  e.stop();
  el.up('.quick_add').down('.pane').toggle();
});
