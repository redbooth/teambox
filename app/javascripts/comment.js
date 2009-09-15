Event.addBehavior({
  ".comment:mouseover": function(e){
    $(this).down('a.hours').show();    
  },
  ".comment:mouseout": function(e){
    $$("div.comment a.hours").each(function(e){ e.hide(); });
  }
});