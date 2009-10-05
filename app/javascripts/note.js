Event.addBehavior({
  ".note:mouseover": function(e){
    $(this).down('p.actions').show();
  },
  ".note:mouseout": function(e){
    $$(".note p.actions").each(function(e){ 
      e.hide();
    });
  }
});