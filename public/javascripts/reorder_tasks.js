document.observe("dom:loaded", function(){
  Task.make_all_sortable();
  Task.bind_cancel_links_on_create_forms();
  Task.bind_cancel_links_on_update_forms();
  Task.bind_creation();
  Task.bind_update();
});