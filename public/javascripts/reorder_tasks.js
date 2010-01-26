document.observe("dom:loaded", function(){
  Task.make_all_sortable();
  // FIXME: replace the following two lines
  // with behaviors defined in low-pro (see task.js)
  Task.bind_cancel_links_on_create_forms();
  Task.bind_cancel_links_on_update_forms();
  Task.bind_creation();
  Task.bind_update();
});