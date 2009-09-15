Event.addBehavior({
  ".comment:mouseover": function(e){
    $(this).down('p.actions').show();
    $(this).down('a.hours').show();    
  },
  ".comment:mouseout": function(e){
    $$("div.comment p.actions").each(function(e){ e.hide(); });
    $$("div.comment a.hours").each(function(e){ e.hide(); });
  }
});