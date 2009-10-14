ToolTips = {
  hide_all: function(){
    $$('.tooltip').each(function(e){e.hide();})
  }
}

Event.onReady(ToolTips.hide_all);

Event.addBehavior({
  "input:focus": function(e){
    if ($($(this).id+'_tooltip') != null){
      tooltip = $($(this).id+'_tooltip')
      tooltip.show();
      offset = $(this).cumulativeOffset();
      tooltip.move(offset[0] + $(this).getWidth() + 10,offset[1]);
    }
  },
  "input:blur": function(e){
    if ($($(this).id+'_tooltip') != null)
      $($(this).id+'_tooltip').hide();
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