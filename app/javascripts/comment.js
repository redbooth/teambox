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

// "Show N previous comments" action in threads
document.on('ajax:success', '.thread .comments .more_comments', function(e, el) {
  el.up('.comments').update(e.memo.responseText).blindDown({ duration: 0.5 })
})

document.on('click', '.thread .comments .more_comments a', function(e, el) {
  el.update("<img src='/images/loading.gif'/>")
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

// Open links inside Comments and Notes textilized areas in new windows
document.on('mouseover', '.textilized a', function(e, link) {
  link.writeAttribute("target", "_blank");
});

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

