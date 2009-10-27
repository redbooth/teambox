Event.addBehavior({
  ".task_list:mouseover": function(e){
    //$(this).down('p.actions').show();
  },
  ".task_list:mouseout": function(e){
    $$(".task_list_wrap p.actions").each(function(e){ 
      //e.hide();
    });
  },
  ".task:mouseover": function(e){
    //$(this).down('p.actions').show();
  },
  ".task:mouseout": function(e){
    $$(".task p.actions").each(function(e){ 
      //e.hide();
    });
  }
});  