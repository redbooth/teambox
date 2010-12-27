var Preview = {
  init: function (textarea) {
    var box = new Element('div', { 'class': 'preview previewBox textilized invisible' })
    textarea.insert({ after: box })

    var formatter = new Showdown.converter;
    formatter.makeHtml = formatter.makeHtml.wrap(function(make) {
      box.update(make(textarea.getValue()))
    })

    textarea.on('keyup', formatter.makeHtml.bind(formatter).throttle(300))
    formatter.makeHtml()
    return box
  },
  toggle: function(box, button) {
    box.toggleClassName('invisible')
    var text = button.innerHTML
    button.update(button.readAttribute('data-alternate')).writeAttribute('data-alternate', text)
  }
}

document.on('click', 'form button.preview', function(e, button) {
  e.stop()

  var form = e.findElement('form'),
      textarea = form.down('textarea'),
      box = form.down('div.preview')

  if (!box) box = Preview.init(textarea)

  Preview.toggle(box, button)
  Preview.manualPreview = true
})

document.on('ajax:success', 'form, div.preview', function(e, form) {
  var box = form.down('div.preview')
  if (box) box.remove()
})

document.on('keyup', 'form textarea', function(e, area) {
  if (Preview.manualPreview) return
  if (e.keyCode == Event.KEY_RETURN) {
    var form = area.up('form'),
        textarea = form.down('textarea'),
        box = form.down('div.preview'),
        button = form.down('button.preview')

    if (!box) box = Preview.init(textarea)
    if (box.hasClassName('invisible')) {
      Preview.toggle(box, button)
    }
  }
})
