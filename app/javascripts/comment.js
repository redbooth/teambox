Event.addBehavior({
  "#sort_uploads:click": function(e){
    Comment.update();
  },
  "#sort_all:click": function(e){
    Comment.update();
  },
  "#sort_hours:click": function(e){
    Comment.update();
  },
  "form .showPreview button:click": function(e){
    $(this).up('form').showPreview();
    return false;
  },
  "form .showPreview a:click": function(e){
    $(this).up('form').closePreview();
    return false;
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
  },
  watch_status: function(){
    $$('.statuses .status').each(function(e){ 
      if(e.hasClassName('open'))
        e.down('select').observe('change', Comment.change_assigned)
      else
        e.observe('click', Comment.change_status)
    });
  },
  change_assigned: function(e){
    Comment.unselect_all_statuses()
    Comment.mark_status_for_assigned(e.element())
  },
  change_status: function(e){
    Comment.unselect_all_statuses()
    Comment.assign_to_nobody()
    Comment.mark_status(e.element())
  },
  unselect_all_statuses: function(){
    $$('.statuses .active').each(function(ee){ ee.removeClassName('active') })
    $$('.statuses input').each(function(ee){ ee.checked = false })    
  },
  mark_status: function(e){
    e.down('input').checked = true
    e.addClassName('active')    
  },
  mark_status_for_assigned: function(e){
    $$('#new_comment option').each(function(ee){ 
      if(ee.value == ''){
        if(ee.selected == true)
          Comment.mark_status($('new_comment').down('.hold'))
        else  
          Comment.mark_status(e.up('.status'))
      }
    })
  },
  assign_to_nobody: function(){
    $$('#new_comment option').each(function(e){ 
      if(e.value == '')
        e.selected = true
      else
        e.selected = false
    })
  },
  make_autocomplete: function(element_id, items){
    new Autocompleter.Local(element_id, element_id + '_list', items, {tokens:[' ']});
  },

  check_edit: function(){
    var list = Comment.edit_watch_list;
    var len = list.length;
    var now = new Date();
    Comment.edit_watch_list = list.reject(function(c){
      if (now > c.date) {
        var el = $(c.id);
        if (el)
          el.down('.actions').hide();
        return true;
      }
      return false;
    });
    
    if (Comment.edit_watch_list.length > 0)
      Comment.edit_watch_timer = setTimeout(Comment.check_edit, 1000);
  },
  cancel_watch_edit: function(){
    if (Comment.edit_watch_timer)
      clearTimeout(Comment.edit_watch_timer);
    Comment.edit_watch_timer = null;
  },
  watch_edit: function(){
    this.cancel_watch_edit();
    var date = new Date();
    
    Comment.edit_watch_list = $$('div.comment').map(function(c){
        var time = new Date();
        time.setTime(c.readAttribute('immutable_at'));
        return {id: c.readAttribute('id'), date:time};
    }).reject(function(c){
        if (date >= c.date) {
          $(c.id + '_actions').hide();
          return true;
        } else {
          $(c.id + '_actions').show();
        }
        return false;
    });
    Comment.check_edit();
  }
};
