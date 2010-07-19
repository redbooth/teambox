document.on('click', '.index_uploads #column .add_button', function(e, button) {
  if (!e.isMiddleClick()) {
    e.preventDefault()
    button.next('form').show()
    button.hide()
  }
})
