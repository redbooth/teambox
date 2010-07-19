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
    var submit_el = $(id + '_submit');
    var loading_el = $(id + '_loading');
    if (value)
    {
      if (submit_el)
        submit_el.hide();
      if (loading_el)
        loading_el.show();
    }
    else
    {
      if (submit_el)
        submit_el.show();
      if (loading_el)
        loading_el.hide();
    }
  },
  create: function(form) {
    var update_id = form.readAttribute('update_id');
    var thread_id_ = form.down('#thread_id');
    thread_id = thread_id_ ? '_' + thread_id_.getValue() : "";

    new Ajax.Request(form.readAttribute('action'), {
      asynchronous: true,
      evalScripts: true,
      method: form.readAttribute('method'),
      parameters: form.serialize(),
      onLoading: function() {
        Comment.setLoading('comment_new' + thread_id, true);
        form.closePreview();
      },
      onFailure: function(response) {
        Comment.setLoading('comment_new' + thread_id, false);
      },
      onSuccess: function(response){
        Comment.setLoading('comment_new' + thread_id, false);
        if ($(document.body).hasClassName('show_tasks'))
          TaskList.updatePage('column', TaskList.restoreColumn);
			},
			onComplete: function(){
				format_posted_date();
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
    var has_threads = form.up('.thread') ? 'true' : 'false';
    new Ajax.Request(form.readAttribute('action_cancel'), {
      method: 'get',
      asynchronous: true,
      evalScripts: true,
      parameters: {'thread': has_threads},
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
    var has_threads = element.up('.thread') ? 'true' : 'false';
    new Ajax.Request(url, {
      method: 'get',
      asynchronous: true,
      evalScripts: true,
      parameters: {'thread': has_threads},
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

  unselect_all_statuses: function(){
    $$('.statuses .active').each(function(ee){ ee.removeClassName('active') })
    $$('.statuses input').each(function(ee){ ee.checked = false })    
  },
  mark_status: function(e){
    e.down('input').checked = true
    e.addClassName('active')    
  },
  mark_status_for_assigned: function(e){
    $$('.new_comment .statuses option').each(function(ee){
      if(ee.value == ''){
        if(ee.selected == true)
          Comment.mark_status(e.up('.statuses').down('.hold'))
        else  
          Comment.mark_status(e.up('.status'))
      }
    })
  },
  paint_status_boxes: function(){
    $$('.statuses input[type=radio]').each(function(el) {
      if (el.checked) {
        el.up('.status').addClassName('active')
      }
    })
  },
  assign_to_nobody: function(){
    $$('.new_comment .statuses option').each(function(e){
      if(e.value == '')
        e.selected = true
      else
        e.selected = false
    })
  },

  check_edit: function(){
    var list = Comment.edit_watch_list;
    var len = list.length;
    var now = new Date();
    Comment.edit_watch_list = list.reject(function(c){
      if (now > c.date) {
        var el = $(c.id);
        if (el)
        {
          el.select('a.taction').each(function(e){ e.hide(); });
          el.select('.tactione').each(function(e){ e.show(); });
        }
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
          $$('#' + c.id + ' .tactione').each(function(e){ e.show(); });
          return true;
        } else {
          $$('#' + c.id + ' a.taction').each(function(e){ e.show(); });
          $$('#' + c.id + ' .tactione').each(function(e){ e.hide(); });
        }
        return false;
    });
    Comment.check_edit();
  }
};

document.on('submit', 'form.new_comment', function(e, form) {
  if (!form.select('input[type=file]').any(function(i){ return i.getValue() })) {
    e.stop();
    Comment.create(form);
  }
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

document.on('click', 'form .showPreview button', function(e, link) {
  e.stop();
  link.up('form').showPreview();
});

document.on('click', 'form .showPreview a', function(e, link) {
  e.stop();
  link.up('form').closePreview();
});

// Open links inside Comments and Notes textilized areas in new windows
document.on('mouseover', '.textilized a', function(e, link) {
  link.writeAttribute("target", "_blank");
});

document.on('change', '.statuses .status.open select', function(e, selectbox) {
  Comment.unselect_all_statuses()
  Comment.mark_status_for_assigned(selectbox)
})
document.on('click', '.statuses .status:not(.open)', function(e, status) {
  Comment.unselect_all_statuses()
  Comment.assign_to_nobody()
  Comment.mark_status(status)
})

document.on('dom:loaded', function() {
  $$('.statuses input[type=checkbox]').each(function(el) {
    if (el.checked) {
      el.up('.status').addClassName('active')
    }
  })
})

document.on('click', 'form.new_comment #comment_upload_link', function(e, link) {
  if (!e.isMiddleClick()) {
    e.preventDefault()
    link.up().next('.upload_area').show()
    link.hide()
  }
})

hideBySelector('.thread form.new_comment .extra')

document.on('focusin', '.thread form.new_comment textarea', function(e, input) {
  input.up('form').down('.extra').setStyle({display: 'block'})
})

document.on('focusin', 'form.new_comment textarea', function(e, input) {
  project_id = input.up('form').readAttribute('data-project') || input.up('form').down('select[name=project_id]').value
  people = _projects_people.get(project_id)
  new Autocompleter.Local(input, input.next('.autocomplete'), people, {tokens:[' ']})
})

// document.on('focusout', '.thread form.new_comment textarea', function(e, input) {
//   if (input.getValue().empty()) {
//     input.up('form').down('.extra').hide()
//   }
// })
