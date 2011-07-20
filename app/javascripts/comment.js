var iframeCounter = 0

Element.addMethods('form', {
  hasFileUploads: function(form) {
    return $(form).select('input[type=file]').any(function(input) {
      return input.getValue()
    })
  },
  isDirty: function(form) {
    form = $(form)
    return form.hasFileUploads() ||
      form.select('textarea').any(function(area) { return area.getValue() != area.innerHTML }) ||
      form.select('input:not([type=submit],[type=hidden],[type=checkbox],[type=radio])').
        any(function(input) { return input.getValue() != (input.readAttribute('value') || '') }) ||
      form.select('select').any(function(select) {
        option = select.down('option[selected]') || select.down('option')
        select.getValue() != option.value
      })
  }
})

document.on('ajax:create', 'form.new_conversation, .thread form', function(e) {
  // don't favor RJS; state we want HTML instead
  e.memo.request.options.requestHeaders = {'Accept': 'text/html'}
})

// async file uploads in comments via iframe
document.on('ajax:before', 'form.new_conversation, form.new_task, .thread form, #facebox form.edit_comment', function(e, form) {
  if (form.hasFileUploads()) {
    e.stop()
    
    var iframeID = 'file_upload_iframe' + (iframeCounter++)
    var iframe = new Element('iframe', { id: iframeID, name: iframeID }).hide()
    $(document.body).insert(iframe)
    form.target = iframeID
    form.insert(new Element('input', { type: 'hidden', name: 'iframe', value: 'true' }))
    
    var callback = function() {
      // contentDocument doesn't work in IE (7)
      var iframeBody = (iframe.contentDocument || iframe.contentWindow.document).body
      
      if (iframeBody.className == "error") {
        var json = iframeBody.firstChild.innerHTML.evalJSON()
        form.fire('ajax:failure', {responseJSON: json})
      } else {
        form.fire('ajax:success', {responseText: iframeBody.innerHTML})
      }

      form.fire('ajax:complete')
      iframe.remove()
      form.target = null
      var extraInput = form.down('input[name=iframe]')
      if (extraInput) extraInput.remove()
    }
    
    // for IE (7)
    iframe.onreadystatechange = function() {
      if (this.readyState == 'complete') callback()
    }
    // non-IE
    iframe.onload = callback

    // we may have cancelled xhr, but we still need to trigger form submit manually
    form.submit()
  }
})

function resetCommentsForm(form) {
  // clear comment and reset textarea height
  form.down('textarea[name*="[body]"]').setValue('').setStyle({ height: '' })
  // clear populated file uploads
  form.select('input[type=file]').each(function(input) {
    if (input.getValue()) input.remove()
  })
  // clear hours
  var hours = form.down('input[name*="[human_hours]"]')
  if (hours) hours.setValue('')
  // hide initially hidden areas
  form.select('.hours_field, .upload_area').invoke('hide')
  // clear errors
  form.select('.error').invoke('remove')
  //clear google docs hidden fields and list items in the file list
  form.select('.google_docs_attachment .fields input').invoke('remove')
  form.select('.google_docs_attachment .file_list li').invoke('remove')
}

// insert new simple conversation into stream after posting
document.on('ajax:success', 'form.new_conversation', function(e, form) {
  resetCommentsForm(form);
  $('activities').insert({top: e.memo.responseText}).down('.thread').highlight({ duration: 1 });
  Task.insertAssignableUsers();

  //disable _method input field for conversation forms on inserting simple conversations
  disableConversationHttpMethodField();
})

// "Show N previous comments" action in threads
document.on('ajax:success', '.thread .comments .more_comments', function(e, el) {
  el.up('.comments').update(e.memo.responseText).blindDown({ duration: 0.5 })
})

document.on('click', '.thread .comments .more_comments a', function(e, el) {
  el.update("<img src='/images/loading.gif'/>")
})

// insert new comment into thread after posting
document.on('ajax:success', '.thread form:not(.not-new-comment)', function(e, form) {
  resetCommentsForm(form)
  if (!e.memo.responseText.blank()) {
    form.up('.thread').down('.comments').insert(e.memo.responseText).
      down('.comment:last-child').highlight({ duration: 1 })
  }
})

document.on('ajax:failure', 'form.new_conversation, .thread form:not(.not-new-comment)', function(e, form) {
  var message = $H(e.memo.responseJSON)
	message.each( function(error) {
		form.down('div.text_area').insertOrUpdate('p.error', error.value)
	})
})

// update edited comment
document.on('ajax:success', '#facebox form.edit_comment', function(e, form) {
  var commentID = form.readAttribute('action').match(/\d+/g).last()
  $('comment_' + commentID).replace(e.memo.responseText)
  Prototype.Facebox.close()
  $('comment_' + commentID).highlight()
})

// remove deleted comment
document.on('ajax:success', '.comment:not(div[data-class=conversation].thread .comment) .actions_menu a[data-method=delete]', function(e, link) {
  e.findElement('.comment').remove()
})

// when deleting comment, remove the conversation if empty: no comments, no title.
document.on('ajax:success', 'div[data-class=conversation].thread .comment .actions_menu a[data-method=delete]', function(e, link) {
	var conversation = e.findElement('.thread')
	if (conversation.select('.comment').length == 1 && conversation.select('.title').length == 0) conversation.remove()
	else e.findElement('.comment').remove()
})

// toggle between hidden upload area and a link to show it
hideBySelector('form .upload_area')

document.on('click', 'form .attach_icon', function(e, link) {
  if (!e.isMiddleClick()) {
    link.up('form').down('.upload_area').forceShow().highlight()
    e.stop()
  }
})

// toggle between hidden time tracking input and a link to show it
hideBySelector('form .hours_field')

document.on('click', 'form .add_hours_icon', function(e, link) {
  link.up('form').down('.hours_field').forceShow().down('input').focus()
  e.stop()
})

// Open links inside Comments and Notes textilized areas in new windows
document.on('mouseover', '.textilized a', function(e, link) {
  link.writeAttribute("target", "_blank");
});

hideBySelector('#activities .thread form.new_comment .extra')

document.on('focusin', '#activities .thread form.new_comment textarea', function(e, input) {
  input.up('form').down('.extra').forceShow()
})

// document.on('focusout', '.thread form.new_comment textarea', function(e, input) {
//   if (input.getValue().empty()) {
//     input.up('form').down('.extra').hide()
//   }
// })

// enable username autocompletion for main textarea in comment forms
document.on('focusin', 'form textarea[name*="[body]"]', function(e, input) {
  var form = e.findElement('form'),
      project = form.readAttribute('data-project-id')
  
  // projects index page has a global comment box with projects selector
  if (!project) {
    var projectSelect = form.down('select[name=project_id]')
    if (projectSelect) project = projectSelect.getValue()
  }
  
  if (project) {
    var people = _people_autocomplete[project],
        autocompleter = input.retrieve('autocompleter')
        
    if (autocompleter) {
      // update options array in case the projects selector changed value
      autocompleter.options.array = people
    } else {
      var container = new Element('div', { 'class': 'autocomplete' }).hide()
      input.insert({ after: container })
      autocompleter = new Autocompleter.Local(input, container, people, { tokens:[' '] })
      input.store('autocompleter', autocompleter)
    }
  }
})
