Event.addBehavior({
  ".task:mouseover": function(e){
      $(this).down('p.actions').show();
  },
  ".task:mouseout": function(e){
    $$(".task p.actions").each(function(e){ 
      e.hide();
    });
  }
});  