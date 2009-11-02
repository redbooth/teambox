Event.addBehavior({
  ".note:mouseover": function(e){
    $(this).down('p.actions').show();
  },
  ".note:mouseout": function(e){
    $$(".note p.actions").each(function(e){ 
      e.hide();
    });
  },
  ".divider:mouseover": function(e){
    $(this).down('p.actions').show();
  },
  ".divider:mouseout": function(e){
    $$(".divider p.actions").each(function(e){ 
      e.hide();
    });
  }  
});
/*
function(e) {
  if (e.target.match('.foo #bar'))
}
*/