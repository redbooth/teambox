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

  setLoading: function(id, value) {
    if (value)
    {
      $(id + '_submit').hide();
      $(id + '_loading').show();
    }
    else
    {
      $(id + '_submit').show();
      $(id + '_loading').hide();
    }
  },
  create: function(form) {
    var update_id = form.readAttribute('update_id');
    new Ajax.Request(form.readAttribute('action'), {
      asynchronous: true,
      evalScripts: true,
      method: form.readAttribute('method'),
      parameters: form.serialize(),
      onLoading: function() {
        Comment.setLoading('comment_new', true);
        $('new_comment').closePreview();
      },
      onFailure: function(response) {
        Comment.setLoading('comment_new', false);
      },
      onSuccess: function(response){
        Comment.setLoading('comment_new', false);
        if ($(document.body).hasClassName('show_tasks'))
          TaskList.updatePage('column', TaskList.restoreColumn);
      }
    });
  },

  submitConvert: function(form) {
    var update_id = form.readAttribute('update_id');
    new Ajax.Request(form.readAttribute('action'), {
      method: 'put',
      asynchronous: true,
      evalScripts: true,
      parameters: form.serialize(),
      onLoading: function() {
        Comment.setLoading(update_id, false);
      },
      onSuccess: function(response){
        Comment.setLoading(update_id, false);
        if ($(document.body).hasClassName('show_tasks'))
          TaskList.updatePage('column', TaskList.restoreColumn);
      },
      onFailure: function(response){
        Comment.setLoading(update_id, false);
      }
    });
  },

  submitEdit: function(form) {
    var update_id = form.readAttribute('update_id');
    new Ajax.Request(form.readAttribute('action'), {
      method: 'put',
      asynchronous: true,
      evalScripts: true,
      parameters: form.serialize(),
      onLoading: function() {
        Comment.setLoading(update_id, false);
      },
      onSuccess: function(response){
        Comment.setLoading(update_id, false);
        if ($(document.body).hasClassName('show_tasks'))
          TaskList.updatePage('column', TaskList.restoreColumn);
      },
      onFailure: function(response){
        Comment.setLoading(update_id, false);
      }
    });
  },

  cancelEdit: function(form) {
    var update_id = form.readAttribute('update_id');
    new Ajax.Request(form.readAttribute('action_cancel'), {
      method: 'get',
      asynchronous: true,
      evalScripts: true,
      onLoading: function() {
        Comment.setLoading(update_id, true);
      },
      onSuccess: function(response){
      },
      onFailure: function(response){
        Comment.setLoading(update_id, false);
      }
    });
  },

  edit: function(element, url) {
    new Ajax.Request(url, {
      method: 'get',
      asynchronous: true,
      evalScripts: true,
      onLoading: function() {
        Actions.setLoading(element, true);
      },
      onSuccess: function(response){
        Actions.setActions(element, false);
        Actions.setLoading(element, false);
      },
      onFailure: function(response){	
        Actions.setLoading(element, false);
      }
    });
  },
 
  destroy: function(element, url) {
    new Ajax.Request(url, {
      method: 'delete',
      asynchronous: true,
      evalScripts: true,
      onLoading: function() {
        Actions.setLoading(element, true);
      },
      onSuccess: function(response){
        Actions.setActions(element, false);
        Actions.setLoading(element, false);
      },
      onFailure: function(response){	
        Actions.setLoading(element, false);
      }
    });
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
          el.select('a.taction').each(function(e){ e.hide(); });
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
          $$('#' + c.id + ' a.taction').each(function(e){ e.hide(); });
          return true;
        } else {
          $$('#' + c.id + ' a.taction').each(function(e){ e.show(); });
        }
        return false;
    });
    Comment.check_edit();
  }
};

document.on('submit', 'form.new_comment', function(e, el) {
  e.stop();
  Comment.create(el);
});

document.on('submit', 'form.edit_comment', function(e, el) {
  e.stop();
  Comment.submitEdit(el);
});

document.on('submit', 'form.convert_comment', function(e, el) {
  e.stop();
  Comment.submitConvert(el);
});

document.on('click', 'a.edit_comment_cancel', function(e, el) {
  e.stop();
  Comment.cancelEdit(el.up('form'));
});

document.on('click', 'a.convert_comment_cancel', function(e, el) {
  e.stop();
  // This one is easy!
  Actions.setActions(el, true);
  el.up('.comment').down('form.convert_comment').remove();
});

document.on('click', 'a.commentEdit', function(e, el) {
  e.stop();
  Comment.edit(el, el.readAttribute('action_url'));
});

document.on('click', 'a.commentConvert', function(e, el) {
  e.stop();
  Comment.edit(el, el.readAttribute('action_url'));
});

document.on('click', 'a.commentDelete', function(e, el) {
  e.stop();
  if (confirm(el.readAttribute('aconfirm')))
    Comment.destroy(el, el.readAttribute('action_url'));
});

document.on('click', '#sort_uploads, #sort_all, #sort_hours', function(e,el) {
  e.stop();
  Comment.update();
});

document.on('click', 'form .showPreview button', function(e,el) {
  e.stop();
  $(this).up('form').showPreview();
});

document.on('click', 'form .showPreview a', function(e,el) {
  e.stop();
  $(this).up('form').closePreview();
});
