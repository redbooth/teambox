Event.addBehavior({
  ".note:mouseover": function(e){
      $$(".note p.actions").invoke('hide');
      $(this).down('p.actions').show();
  },
  ".note:mouseout": function(e){
  }
});

function notesUpdate(e){
  alert('hi');
}