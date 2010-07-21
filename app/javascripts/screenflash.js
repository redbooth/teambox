Screenflash = {
  display: function(message, seconds) {
    if(typeof(seconds) == 'undefined') { seconds = 3 }
    $('screenflash').update(message)
    $('screenflash').show()
    setTimeout(function(){ $('screenflash').fade() }, seconds*1000)
  }
}
