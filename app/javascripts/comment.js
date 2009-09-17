Event.addBehavior({
  ".comment:mouseover": function(e){
    $(this).down('a.hours').show();    
  },
  ".comment:mouseout": function(e){
    $$("div.comment a.hours").each(function(e){ e.hide(); });
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