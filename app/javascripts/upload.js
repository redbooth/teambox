document.on('click', '.index_uploads #column .add_button', function(e) {
  if (!e.isMiddleClick()) {
    e.preventDefault()
    this.next('form').show()
    this.hide()
  }
})
