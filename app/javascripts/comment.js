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
    var el = $(this);
    var block = el.up();
    if (block.readAttribute('showing') == '1')
      return false;
    
    // Set showing, cancel any removals
    block.writeAttribute('showing', '1');
    el.disabled = true;
    el.down('.default').hide();
    el.down('.showing').show();
    if (block.readAttribute('removing') == '1') {
      block.writeAttribute('removing', '0');
      return false;
    }
    
    // New updater needed!
    var form = block.up('form');
    var previewBox = form.down('.previewBox');
    var updater = null;
    var updaterCallback = function(transport) {
      console.log("WOOOOO");
      if (block.readAttribute('removing') == '1') {	
        block.writeAttribute('removing', '0');
        updater.stop();
      } else {
        previewBox.innerHTML = transport.responseText;
        if (!previewBox.visible()) {
          previewBox.blindDown({duration: 0.3});
          el.hide();
          el.up().down('a').show();
        }
      }
    }
    
    updater = new Ajax.PeriodicalFormUpdater(previewBox, form, { 
      method: 'post', 
      frequency: 2,
      decay: 2,
      onSuccess: updaterCallback,
      onFailure: updaterCallback
    });
	
    return false;
  },
  "form .showPreview a:click": function(e){
    var el = $(this);
    var block = el.up();
    var previewBox = block.up('form').down('.previewBox');
    
    var button = el.up().down('button');
    el.hide();
    button.down('.default').show();
    button.down('.showing').hide();
    button.show().disabled = false;
    
    block.writeAttribute('showing', '0');
    block.writeAttribute('removing', '1');
    if (previewBox.visible())
      previewBox.blindUp({duration: 0.15});
    
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
  }
};
