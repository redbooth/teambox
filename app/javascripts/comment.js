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
document.on('ajax:before', 'form.new_conversation, .thread form, #facebox form.edit_comment', function(e, form) {
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
  // clear and hide the preview area
  var preview = form.down('.previewBox')
  if (preview && preview.visible()) togglePreviewBox(preview.update(''))
  // clear hours
  var hours = form.down('input[name*="[human_hours]"]')
  if (hours) hours.setValue('')
  // hide initially hidden areas
  form.select('.hours_field, .upload_area').invoke('hide')
  // clear errors
  form.select('.error').invoke('remove')
}

// insert new simple conversation into stream after posting
document.on('ajax:success', 'form.new_conversation', function(e, form) {
  resetCommentsForm(form)
  $('activities').insert({top: e.memo.responseText}).down('.thread').highlight({ duration: 1 })
})

// "Show N previous comments" action in threads
document.on('ajax:success', '.thread .comments .more_comments', function(e, el) {
  el.up('.comments').update(e.memo.responseText).highlight({ duration: 2 })
})

// insert new comment into thread after posting
document.on('ajax:success', '.thread form', function(e, form) {
  resetCommentsForm(form)
  form.up('.thread').down('.comments').insert(e.memo.responseText).
    down('.comment:last-child').highlight({ duration: 1 })
})

document.on('ajax:failure', 'form.new_conversation, .thread form', function(e, form) {
  var message = e.memo.responseJSON.first()[1]
  form.down('div.text_area').insert(new Element('p', { 'class': 'error' }).update(message))
})

// update edited comment
document.on('ajax:success', '#facebox form.edit_comment', function(e, form) {
  var commentID = form.readAttribute('action').match(/\d+/g).last()
  $('comment_' + commentID).replace(e.memo.responseText)
  Prototype.Facebox.close()
  $('comment_' + commentID).highlight()
})

// remove deleted comment
document.on('ajax:success', '.comment .actions_menu a[data-method=delete]', function(e, link) {
  e.findElement('.comment').remove()
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
});

function startStopwatch(elapsedTime, task_id) {
  var stopwatch = $('stopwatch');
  stopwatch.show();

  var timerDisplay = stopwatch.down('.timer');
  document.cookies().unset('_teambox.task.timer');
  var timer = stopwatch.retrieve('task.timer', new Stopwatch(function(watch){
     timerDisplay.update(watch.toString());
     var elapsedTime = watch.getElapsed();
     var elapsedSeconds = elapsedTime.hours * 60 * 60  + elapsedTime.minutes * 60 + elapsedTime.seconds;
     document.cookies().set('_teambox.task.timer', task_id + '-' + elapsedSeconds, {path: '/'});
  }, 1000));

  if (elapsedTime) {
    timer.setElapsed(0,0,elapsedTime);
  }
  timer.start();
};

document.observe("dom:loaded", function() {
  console.log("dom:loaded...should enter debugger");
  var taskElapsedTime = document.cookies().get('_teambox.task.timer');
  if (taskElapsedTime) {
    var values = taskElapsedTime.split(/-/);
    console.log("values: id: " + values[0] + ' s: ' + values[1]);
    var elapsedTime = parseInt(values[1],10);
    var task_id = values[0];
    startStopwatch(elapsedTime, task_id);
  }
});

document.on('click', '.start-timer', function(e, element) {
  var task_id = $$('.task')[0].id;
  startStopwatch(null,task_id);
  e.stop();
});

document.on('click', '.stop-timer', function(e, element) {
  var stopwatch = $('stopwatch');
  var timerDisplay = stopwatch.down('.timer');
  var timer = stopwatch.retrieve('task.timer');

  if (timer.started) {
    timer.stop();
    //ajax post of hours added

    var task_id = document.cookies().get('_teambox.task.timer').split(/-/)[0];
    var elapsedTime = timer.getElapsed();
    var elapsedSeconds = elapsedTime.hours * 60 * 60  + elapsedTime.minutes * 60 + elapsedTime.seconds;

    alert(elapsedSeconds + ' elapsed for ' + task_id);
    document.cookies().unset('_teambox.task.timer');
    timer.reset();
    timerDisplay.update(timer.toString());
  }

  e.stop();
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

function togglePreviewBox(previewBox, enabled, button) {
  if (enabled == undefined) enabled = previewBox.visible()
  if (button == undefined) button = previewBox.up('form').down('button.preview')

  if (enabled) previewBox.hide()
  else previewBox.show()

  var text = button.innerHTML
  button.update(button.readAttribute('data-alternate')).writeAttribute('data-alternate', text)
}

document.on('click', 'form button.preview', function(e, button) {
  e.stop()

  var enabled = false,
      textarea = e.findElement('form').down('textarea'),
      previewBox = textarea.next('.previewBox')

  if (!previewBox) {
    previewBox = new Element('div', { 'class': 'previewBox' })
    textarea.insert({ after: previewBox })

    var formatter = new Showdown.converter;
    formatter.makeHtml = formatter.makeHtml.wrap(function(make) {
      previewBox.update(make(textarea.getValue()))
    })

    textarea.on('keyup', formatter.makeHtml.bind(formatter).throttle(300))
    formatter.makeHtml()
  } else {
    enabled = previewBox.visible()
  }

  togglePreviewBox(previewBox, enabled, button)
})

new PeriodicalExecuter(function() {
  var now = new Date()

  $$('.comment[data-editable-before] a[data-uneditable-message]').each(function(link) {
    var timestamp = link.up('.comment').readAttribute('data-editable-before'),
        editableBefore = new Date(parseInt(timestamp))

    if (now >= editableBefore) {
      var message = link.readAttribute('data-uneditable-message')
      link.replace(new Element('span').update(message))
    }
  })
}, 30)
