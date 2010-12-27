// Displays a spinner in the header to indicate that something is loading
window.Loading = {
  show: function() {
    $('global_loading_icon').show()
  },
  hide: function() {
    $('global_loading_icon').hide()
  }
}
