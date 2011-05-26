var iframeCounter = 0

Element.addMethods('form', {
  hasFileUploads: function(form) {
    return $(form).select('input[type=file]').any(function(input) {
      return input.getValue()
    })
  },
  hasEmptyFileUploads: function(form) {
    return $(form).select('input[type=file]').any(function(input) {
      return input.value == ''
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

    var authToken = $$('meta[name=csrf-token]').first().readAttribute('content'),
    authParam = $$('meta[name=csrf-param]').first().readAttribute('content')
    if (form[authParam]) {
      form[authParam].value = authToken }
    else {
      var token = new Element('input', { type: 'hidden', name: authParam, value: authToken }).hide()
      form.insert(token)
    }

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
  // clear private box
  var private_opts = form.down('.private_options');
  if (private_opts) {
	private_opts.childElements().invoke('remove');
	private_opts.hide();
	var trigger = form.down('.private_switch');
	if (trigger) trigger.removeAttribute('form-present');
  }
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

  my_user.stats.conversations++;
  document.fire("stats:update");

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
  var comment_data = e.memo.responseText
  var conversation_data = e.memo.headerJSON
  var thread = form.up('.thread')

  if (conversation_data) {
    // Update privacy status
    if (conversation_data.is_private) {
      if (!thread.hasClassName('private'))
        thread.addClassName('private')
    } else {
      thread.removeClassName('private')
    }

    // sync attributes
    thread.writeAttribute('data-user-id', conversation_data.user_id)
    thread.writeAttribute('data-watcher-ids', (conversation_data.watchers||[]).join(','))
  }

  if (!e.memo.responseText.blank()) {
    var new_comment = thread.down('.comments').insert(e.memo.responseText).down('.comment:last-child')
    new_comment.highlight({ duration: 1 })

    // update excerpt in collapsed threads
    var body = new_comment.down('.body'),
        start = (body.down('.assigned_transition') || body.down('.before')),
        excerpt = start.nextSiblings().map(function(e){return e.innerHTML}).join(' ').stripTags()
    thread.down('.comment_header').
           down('.excerpt').
           update('<strong>' + body.down('.before').down('.user').innerHTML + '</strong> ' + excerpt)
  }
  my_user.stats.conversations++;
  document.fire("stats:update");
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
  var form = input.up('form')
  var extra = form.down('.extra')
  extra.forceShow()
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
    var people = _people[project],
        autocompleter = input.retrieve('autocompleter'),
        all = "@all <span class='informal'>" + I18n.translations.conversations.watcher_fields.people_all + "</span>"

    people = [all].concat(people.collect(function (p) {
      return "@" + p[1] + " <span class='informal'>" + p[2] + "</span>"
    }))
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

document.on('focusin', 'form#new_invitation input#invitation_user_or_email', function(e, input) {
  var form = e.findElement('form')
  var people = (new Hash(_people_autocomplete)).values().flatten().uniq().reject(function(e) { return e.match('@all') }),
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
})

