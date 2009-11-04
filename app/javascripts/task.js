Event.addBehavior({
  ".task:mouseover": function(e){
    $(this).down('img.drag').show();
    $(this).down('img.task_status').hide();
  },
  ".task:mouseout": function(e){
    $$(".task img.drag").each(function(e){ e.hide(); });
    $$(".task img.task_status").each(function(e){ e.show(); });
  }
});  