Fyi = {
  hide_all: function(){
    $$('.fyi').each(function(e){e.hide();})
  }
}

Event.onReady(Fyi.hide_all);

Event.addBehavior({
  "input:focus": function(e){
    if ($($(this).id+'_fyi') != null){
      tooltip = $($(this).id+'_fyi')
      tooltip.show();
      offset = $(this).cumulativeOffset();
      tooltip.move(offset[0] + $(this).getWidth() + 10,offset[1]);
    }
  },
  "input:blur": function(e){
    if ($($(this).id+'_fyi') != null)
      $($(this).id+'_fyi').hide();
  }  
});  

Element.addMethods({
  move: function(element,x,y){
    element = $(element);
    element.style.left = x+'px';
    element.style.top = y+'px';
    return element;
  }  
});