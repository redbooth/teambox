Event.addBehavior({
  ".comment:mouseover": function(e){
    $(this).down('p.actions').show();
  },
  ".comment:mouseout": function(e){
    $$("div.comment p.actions").each(function(e){ 
      e.hide();
    });
  }
});