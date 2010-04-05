Event.addBehavior({
  "#reorder_task_lists_link:click": function(e){
    $$('.task_list_container').each(function(value) { value.toggleClassName('reordering'); });
    $('reorder_task_lists_link').hide();
    $('done_reordering_task_lists_link').show();
  },
  "#done_reordering_task_lists_link:click": function(e){
    $$('.task_list_container').each(function(value) { value.toggleClassName('reordering'); });
    $('reorder_task_lists_link').show();
    $('done_reordering_task_lists_link').hide();
  }
});