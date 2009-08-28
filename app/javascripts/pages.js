Event.addBehavior({
  "#name:mouseover": function(e){
      hideAllActions();
      $(this).down('p.actions').show();
  },
  "#name:mouseout": function(e){
    $$("#name p.actions").invoke('hide');
  },
  
  ".section_divider:mouseover": function(e){
      hideAllActions();
      $(this).down('p.actions').show();
  },
  ".section_divider:mouseout": function(e){
    $$(".insert p.actions").invoke('hide');
  }  
});

function hideAllActions() {
  $$('p.actions').invoke('hide');
}