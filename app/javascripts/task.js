Event.addBehavior({
  ".task_list:mouseover": function(e){
    $(this).down('img.drag').show();
    $(this).down('img.task_status').show();
  },
  ".task_list:mouseout": function(e){
    $$(".task_list_wrap img.drag").each(function(e){e.hide();});
  },
  ".task:mouseover": function(e){
    $(this).down('img.drag').show();
    $(this).down('img.task_status').hide();
  },
  ".task:mouseout": function(e){
    $$(".task img.drag").each(function(e){ e.hide(); });
    $$(".task img.task_status").each(function(e){ e.show(); });
  }
});  