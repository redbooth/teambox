Event.addBehavior({
  '.comment_body:focus':function(e){
    this.className = 'comment_body_focused';
    $(this).innerHTML = '';
    $(this).up('#new_comment').down('.extra').show();
  },
  '.comment_body:blur':function(e){
      if ($F(this) == ''){
        this.className = 'comment_body'; 
        this.innerHTML = 'Write a comment...';
        $(this).up('#new_comment').down('.extra').hide();
      }else{
        this.className = 'comment_body_focused';
        $(this).up('#new_comment').down('.extra').show();
      }  
  },
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
  "#sort_uploads:click": function(e){
    Comment.update();
  },
  "#sort_all:click": function(e){
    Comment.update();
  },
  "#sort_hours:click": function(e){
    Comment.update();
  }
});

Comment = {
  update_uploads_current: function(e) {
    if (e.select('div.upload_thumbnail').length == 0)
      e.hide();
    else
      e.show();
  },
  update: function() {
    var params = {};
    if ($('sort_uploads').checked) {
      params = { show: 'uploads' };
    } else if ($('sort_hours').checked) {
      params = { show: 'hours' };
    }
    new Ajax.Request(comments_update_url, { method: 'get', parameters: $H(params).merge(comments_parameters) });
  }
};