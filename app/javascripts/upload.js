Event.addBehavior({
  ".upload_wrap:mouseover": function(e){
    $(this).down('p.actions').show();
  },
  ".upload_wrap:mouseout": function(e){
    $$(".upload_wrap p.actions").each(function(e){ 
      e.hide();
    });
  }
});