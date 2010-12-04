# Preview text input, showing parsed Markdown under the textarea

Preview =
  init: (textarea) ->
    box = new Element 'div', 'class': 'preview previewBox textilized invisible'
    textarea.insert after: box

    formatter = new Showdown.converter
    formatter.makeHtml = formatter.makeHtml.wrap (make) ->
      box.update make(textarea.getValue())

    textarea.on 'keyup', formatter.makeHtml.bind(formatter).throttle(300)
    formatter.makeHtml()
    return box

  toggle: (box, button) ->
    box.toggleClassName 'invisible'
    text = button.innerHTML
    button.update(button.readAttribute('data-alternate')).writeAttribute('data-alternate', text)

document.on 'click', 'form button.preview', (e, button) ->
  e.stop()
  form = e.findElement('form')
  textarea = form.down('textarea')
  box = form.down('div.preview')
  box = Preview.init(textarea) unless box
  Preview.toggle box, button

document.on 'ajax:success', 'form, div.preview', (e, form) ->
  box = form.down('div.preview')
  box.remove() if box
