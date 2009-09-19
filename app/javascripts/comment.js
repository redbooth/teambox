Event.addBehavior({
  ".comment:mouseover": function(e){
    $(this).className = 'comment comment_hover'
  },
  ".comment:mouseout": function(e){
    $$("div.comment").each(function(e){ e.className = 'comment'; });
  },
  ".activity:mouseover": function(e){
    $(this).className = 'activity activity_hover'
  },
  ".activity:mouseout": function(e){
    $$("div.activity").each(function(e){ e.className = 'activity'; });
  },  
  "#sort_hours:click": function(e){
    alert($(this).checked);
  }
});

Comment = {
  update_uploads_current: function(e) {
    if (e.select('div.upload_thumbnail').length == 0)
      e.hide();
    else
      e.show();
  }
};